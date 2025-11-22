module Blazer
  module Ai
    class Engine < ::Rails::Engine
      isolate_namespace Blazer::Ai

      # Engine views are automatically available via Rails view path resolution.
      # Users can override by creating their own views in:
      #   app/views/blazer/ai/queries/_generate_sql_button.html.erb
    end
  end
end
