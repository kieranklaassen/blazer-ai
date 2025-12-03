# Rack middleware that injects the AI button into Blazer query pages
# and handles the AI generation API endpoint.
module Blazer
  module Ai
    class Middleware
      def initialize(app)
        @app = app
      end

      def call(env)
        # Handle AI generation endpoint
        if ai_generate_request?(env)
          return handle_ai_generate(env)
        end

        status, headers, response = @app.call(env)

        # Only inject into HTML responses for Blazer query pages
        if inject_button?(env, headers)
          body = extract_body(response)
          if body.include?("id=\"editor\"") || body.include?("id=\"editor-container\"")
            body = inject_ai_script(body)
            headers["Content-Length"] = body.bytesize.to_s
            response = [ body ]
          end
        end

        [ status, headers, response ]
      end

      private

      def ai_generate_request?(env)
        env["REQUEST_METHOD"] == "POST" &&
          env["PATH_INFO"].to_s.end_with?("/ai/generate_sql")
      end

      def handle_ai_generate(env)
        require "json"

        request = Rack::Request.new(env)
        params = begin
          JSON.parse(request.body.read)
        rescue
          {}
        end
        query_params = params["query"] || {}

        # Basic validation
        name = query_params["name"].to_s.strip
        description = query_params["description"].to_s.strip

        if name.empty? && description.empty?
          return json_response({ error: "Name or description required" }, 422)
        end

        # Check if AI is enabled
        unless Blazer::Ai.configuration.enabled?
          return json_response({ error: "AI features are disabled" }, 403)
        end

        # Rate limiting
        identifier = "ip:#{request.ip}"
        rate_limiter = RateLimiter.new
        begin
          rate_limiter.check_and_track!(identifier: identifier)
        rescue RateLimiter::RateLimitExceeded => e
          return json_response({ error: e.message, retry_after: e.retry_after }, 429)
        end

        # Find data source
        data_source = find_data_source(query_params["data_source"])

        # Generate SQL
        generator = SqlGenerator.new(
          params: { name: name, description: description },
          data_source: data_source
        )

        begin
          sql = generator.call
          json_response({ sql: sql }, 200)
        rescue SqlValidator::ValidationError
          json_response({ error: "Generated SQL failed safety validation" }, 422)
        rescue SqlGenerator::GenerationError => e
          json_response({ error: e.message }, 422)
        rescue => e
          Rails.logger.error("[BlazerAI] Generation error: #{e.class}: #{e.message}") if defined?(Rails.logger)
          json_response({ error: "An error occurred while generating SQL" }, 422)
        end
      end

      def find_data_source(data_source_id)
        return nil if data_source_id.to_s.empty?
        return nil unless defined?(Blazer) && Blazer.respond_to?(:data_sources)
        Blazer.data_sources[data_source_id]
      end

      def json_response(data, status)
        body = JSON.generate(data)
        [
          status,
          { "Content-Type" => "application/json", "Content-Length" => body.bytesize.to_s },
          [ body ]
        ]
      end

      def inject_button?(env, headers)
        return false unless headers["Content-Type"]&.include?("text/html")
        path = env["PATH_INFO"].to_s
        path.match?(%r{/queries(/new|/\d+(/edit)?)?$})
      end

      def extract_body(response)
        body = +""
        response.each { |part| body << part }
        response.close if response.respond_to?(:close)
        body
      end

      def inject_ai_script(body)
        generate_path = Blazer::Ai::UrlHelper.blazer_ai_generate_sql_path
        script = build_script(generate_path)

        # Find the last </body> tag using rindex to avoid regex issues
        closing_body_index = body.rindex("</body>")
        return body unless closing_body_index

        # Insert script before the closing body tag by manual string slicing
        body[0...closing_body_index] + script + body[closing_body_index..-1]
      end

      def build_script(generate_path)
        <<~HTML
          <style>
            #blazer-ai-btn { margin-right: 5px; cursor: pointer; }
            #blazer-ai-btn.loading { opacity: 0.7; }
            #blazer-ai-btn .spinner { display: none; width: 12px; height: 12px; border: 2px solid transparent; border-top-color: currentColor; border-radius: 50%; animation: bas 0.8s linear infinite; margin-right: 4px; vertical-align: middle; }
            #blazer-ai-btn.loading .spinner { display: inline-block; }
            @keyframes bas { to { transform: rotate(360deg); } }
            #blazer-ai-error { display: none; margin-top: 8px; padding: 8px 12px; background: #f8d7da; border: 1px solid #f5c6cb; border-radius: 4px; color: #721c24; font-size: 13px; }
            #blazer-ai-error.show { display: block; }
          </style>
          <script>
          (function() {
            var BA = {
              loading: false,
              path: "#{generate_path}",
              init: function() {
                var self = this, attempts = 0;
                var iv = setInterval(function() {
                  var btn = document.querySelector('input.btn-success[type="submit"][value="Create"], input.btn-success[type="submit"][value="Update"]');
                  if (btn && !document.getElementById('blazer-ai-btn')) {
                    clearInterval(iv);
                    self.inject(btn);
                  } else if (++attempts > 50) clearInterval(iv);
                }, 100);
                document.addEventListener('keydown', function(e) {
                  if ((e.ctrlKey || e.metaKey) && e.shiftKey && e.key === 'G') { e.preventDefault(); BA.generate(); }
                });
              },
              inject: function(createBtn) {
                var btn = document.createElement('a');
                btn.id = 'blazer-ai-btn';
                btn.className = 'btn btn-info';
                btn.innerHTML = '<span class="spinner"></span>AI Generate';
                btn.onclick = function(e) { e.preventDefault(); BA.generate(); };
                createBtn.parentNode.insertBefore(btn, createBtn);
                var err = document.createElement('div');
                err.id = 'blazer-ai-error';
                var closeBtn = document.createElement('span');
                closeBtn.style.cssText = 'float:right;cursor:pointer';
                closeBtn.textContent = 'x';
                closeBtn.onclick = function() { err.classList.remove('show'); };
                var msgSpan = document.createElement('span');
                msgSpan.className = 'msg';
                err.appendChild(closeBtn);
                err.appendChild(msgSpan);
                createBtn.parentNode.parentNode.appendChild(err);
              },
              generate: function() {
                if (this.loading) return;
                var name = (document.querySelector('input[name="query[name]"]') || {}).value || '';
                var desc = (document.querySelector('textarea[name="query[description]"]') || {}).value || '';
                var ds = (document.querySelector('select[name="query[data_source]"]') || {}).value || '';
                if (!name.trim() && !desc.trim()) { this.error('Enter a query name or description first.'); return; }
                this.setLoading(true);
                this.hideError();
                fetch(this.path, {
                  method: 'POST',
                  headers: { 'Content-Type': 'application/json', 'X-CSRF-Token': (document.querySelector('meta[name="csrf-token"]') || {}).content || '' },
                  body: JSON.stringify({ query: { name: name, description: desc, data_source: ds } })
                })
                .then(function(r) { return r.json().then(function(d) { return { status: r.status, data: d }; }); })
                .then(function(r) {
                  BA.setLoading(false);
                  if (r.status === 429) BA.error('Rate limit. Wait ' + (r.data.retry_after || 60) + 's.');
                  else if (r.status !== 200 || r.data.error) BA.error(r.data.error || 'Generation failed.');
                  else if (r.data.sql) BA.insertSQL(r.data.sql);
                })
                .catch(function() { BA.setLoading(false); BA.error('Network error.'); });
              },
              insertSQL: function(sql) {
                if (typeof editor !== 'undefined') { editor.setValue(sql, 1); editor.focus(); }
                else { var ta = document.querySelector('textarea[name="query[statement]"]'); if (ta) { ta.value = sql; ta.focus(); } }
              },
              setLoading: function(v) { this.loading = v; var b = document.getElementById('blazer-ai-btn'); if (b) b.classList.toggle('loading', v); },
              error: function(m) { var e = document.getElementById('blazer-ai-error'); if (e) { e.querySelector('.msg').textContent = m; e.classList.add('show'); } },
              hideError: function() { var e = document.getElementById('blazer-ai-error'); if (e) e.classList.remove('show'); }
            };
            if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', function() { BA.init(); });
            else BA.init();
          })();
          </script>
        HTML
      end
    end
  end
end
