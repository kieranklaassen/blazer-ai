require "rails/generators"

module BlazerAi
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.join(__dir__, "templates")

      def copy_initializer
        template "initializer.rb.tt", "config/initializers/blazer_ai.rb"
      end
    end
  end
end
