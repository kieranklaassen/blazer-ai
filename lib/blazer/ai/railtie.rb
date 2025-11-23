# Integrates Blazer AI into Rails applications.
# Injects routes into Blazer::Engine and sets up view paths.
class Blazer::Ai::Railtie < ::Rails::Railtie
  initializer "blazer_ai.load", before: :load_config_initializers do
    require "blazer/ai/engine"
  end

  initializer "blazer_ai.prepend_view_paths", after: :load_config_initializers do |app|
    ActiveSupport.on_load(:action_controller) do
      append_view_path(Blazer::Ai::Engine.root.join("app/views"))
    end
  end

  # Inject routes directly into Blazer::Engine to avoid nested engine routing issues
  initializer "blazer_ai.extend_routes", after: "blazer.routes" do |app|
    if defined?(Blazer::Engine)
      Blazer::Engine.routes.prepend do
        post "/ai/generate_sql" => "ai/queries#create", as: "blazer_ai_generate_sql"
      end

      ActiveSupport.on_load(:action_controller) do
        helper Blazer::Ai::UrlHelper
      end
    end
  end
end
