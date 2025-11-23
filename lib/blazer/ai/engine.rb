# Rails engine for Blazer AI.
module Blazer
  module Ai
    class Engine < ::Rails::Engine
      isolate_namespace Blazer::Ai
    end
  end
end
