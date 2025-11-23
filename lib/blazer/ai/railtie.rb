# Integrates Blazer AI into Rails applications.
class Blazer::Ai::Railtie < ::Rails::Railtie
  initializer "blazer_ai.load" do
    require "blazer/ai/engine"
    require "blazer/ai/middleware"
  end

  # Middleware handles both UI injection and API endpoint
  initializer "blazer_ai.middleware" do |app|
    app.middleware.use Blazer::Ai::Middleware
  end
end
