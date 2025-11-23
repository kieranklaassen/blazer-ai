# Provides URL helpers for Blazer AI routes.
# Computes path fresh each time to handle development reloads
# and multi-tenant scenarios where mount points may vary.
module Blazer::Ai::UrlHelper
  # Returns the path to the generate_sql endpoint.
  # Automatically detects Blazer's mount point.
  def self.blazer_ai_generate_sql_path
    path = "/ai/generate_sql"

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
