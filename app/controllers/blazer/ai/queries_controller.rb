module Blazer
  module Ai
    class QueriesController < ApplicationController
      before_action :ensure_ai_enabled, only: [:create]

      # POST /blazer/ai/queries (generate SQL)
      def create
        # Atomic rate limit check and track - prevents race conditions
        rate_limiter.check_and_track!(identifier: current_identifier)

        data_source = find_data_source
        generator = SqlGenerator.new(
          params: query_params,
          data_source: data_source
        )

        sql = generator.call
        log_generation(query_params, sql)

        render json: { sql: sql }
      rescue SqlValidator::ValidationError => e
        render json: { error: "Generated SQL failed safety validation" }, status: :unprocessable_entity
      rescue SqlGenerator::GenerationError => e
        render json: { error: e.message }, status: :unprocessable_entity
      rescue RateLimiter::RateLimitExceeded => e
        render json: { error: e.message, retry_after: e.retry_after }, status: :too_many_requests
      rescue StandardError => e
        Rails.logger.error("[BlazerAI] Generation error: #{e.class}: #{e.message}")
        Rails.logger.error(e.backtrace.first(10).join("\n")) if e.backtrace
        render json: { error: "An error occurred while generating SQL. Please try again." }, status: :unprocessable_entity
      end

      private

      def query_params
        params.require(:query).permit(:name, :description, :data_source)
      end

      def find_data_source
        data_source_id = params.dig(:query, :data_source)
        return nil if data_source_id.blank?
        return nil unless defined?(Blazer) && Blazer.respond_to?(:data_sources)

        Blazer.data_sources[data_source_id]
      end

      def ensure_ai_enabled
        unless Blazer::Ai.configuration.enabled?
          render json: { error: "AI features are disabled" }, status: :forbidden
        end
      end

      def rate_limiter
        @rate_limiter ||= RateLimiter.new
      end

      def current_identifier
        # Use Blazer's authentication if available (inherited from BaseController)
        if respond_to?(:blazer_user, true) && blazer_user
          "user:#{blazer_user.try(:id) || blazer_user}"
        else
          "ip:#{request.remote_ip}"
        end
      end

      def log_generation(params, sql)
        return unless Rails.logger

        Rails.logger.info("[BlazerAI] SQL generated for #{current_identifier}")
        Rails.logger.debug("[BlazerAI] Name: #{params[:name].to_s.truncate(100)}")
        Rails.logger.debug("[BlazerAI] Description: #{params[:description].to_s.truncate(200)}")
        Rails.logger.debug("[BlazerAI] SQL: #{sql.truncate(500)}")
      end
    end
  end
end

