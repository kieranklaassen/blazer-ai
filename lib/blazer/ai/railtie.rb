module Blazer
  module Ai
    class Railtie < ::Rails::Railtie
      # Load the engine first to ensure it's defined
      initializer "blazer_ai.load", before: :load_config_initializers do
        require "blazer/ai/engine"
      end

      # Explicitly load our controllers so they're available when routes are accessed
      config.to_prepare do
        require_dependency Blazer::Ai::Engine.root.join("app/controllers/blazer/ai/application_controller").to_s
        require_dependency Blazer::Ai::Engine.root.join("app/controllers/blazer/ai/queries_controller").to_s
      end

      # Set up view paths to include our partials
      initializer "blazer_ai.prepend_view_paths", after: :load_config_initializers do |app|
        ActiveSupport.on_load(:action_controller) do
          # Add our engine's view path to controllers
          append_view_path(Blazer::Ai::Engine.root.join("app/views"))
        end
      end

      # Add our routes directly to Blazer::Engine instead of mounting a separate engine
      # This avoids routing issues with nested engines
      initializer "blazer_ai.extend_routes", after: "blazer.routes" do |app|
        if defined?(Blazer::Engine)
          Blazer::Engine.routes.prepend do
            # Route is within Blazer::Engine, so controller namespace is already Blazer::
            post "/ai/generate_sql" => "ai/queries#create", as: "blazer_ai_generate_sql"
          end

          # Add helper methods to make route helpers available in controllers & views
          ActiveSupport.on_load(:action_controller) do
            helper Blazer::Ai::UrlHelper
          end
        end
      end
    end
  end
end
