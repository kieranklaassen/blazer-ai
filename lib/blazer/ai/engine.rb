# Rails engine for Blazer AI.
# Views can be overridden by creating app/views/blazer/ai/queries/_generate_sql_button.html.erb
class Blazer::Ai::Engine < ::Rails::Engine
  isolate_namespace Blazer::Ai
end
