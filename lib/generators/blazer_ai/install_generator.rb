require "rails/generators"

module BlazerAi
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      def copy_initializer
        copy_file "blazer_ai.rb", "config/initializers/blazer_ai.rb"
      end
    end
  end
end
