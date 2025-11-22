module Blazer
  module Ai
    module UrlHelper
      # Returns the path to the generate_sql endpoint
      # Uses the engine's routing to properly resolve the full path
      # including any mount points (e.g., /insights/ai/generate_sql)
      def self.blazer_ai_generate_sql_path
        @cached_path ||= begin
          # Our route is /ai/generate_sql in Blazer::Engine
          path = "/ai/generate_sql"

          # Find where Blazer::Engine is mounted in the main app
          if defined?(Rails.application)
            main_route = Rails.application.routes.routes.find { |r| r.name == "blazer" }
            if main_route
              blazer_mount = main_route.path.spec.to_s.gsub("(.:format)", "")
              path = blazer_mount + path
            end
          end

          path
        end
      end
    end
  end
end
