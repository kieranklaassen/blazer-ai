module Blazer
  module Ai
    class Railtie < ::Rails::Railtie
      # Load the engine first to ensure it's defined
      initializer "blazer_ai.load", before: :load_config_initializers do
        require "blazer/ai/engine"
      end

      # Set up view paths to include our partials
      initializer "blazer_ai.prepend_view_paths", after: :load_config_initializers do |app|
        ActiveSupport.on_load(:action_controller) do
          # Add our engine's view path to controllers
          append_view_path(Blazer::Ai::Engine.root.join("app/views"))
        end
      end

      # Mount our engine inside the Blazer engine's routes
      initializer "blazer_ai.extend_routes", after: "blazer.routes" do |app|
        # Only mount if Blazer::Engine is defined
        if defined?(Blazer::Engine)
          Blazer::Engine.routes.prepend do
            # Mount our engine at /ai path
            mount Blazer::Ai::Engine, at: "/ai", as: "blazer_ai"
          end

          # Add helper methods to make route helpers available in controllers & views
          # This ensures route helpers work consistently within Blazer's context
          ActiveSupport.on_load(:action_controller) do
            helper Blazer::Ai::Engine.routes.url_helpers
          end
        end
      end
    end
  end
end
