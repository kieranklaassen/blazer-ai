require "rails/generators"

module BlazerAi
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      def copy_blazer_ai_initializer
        copy_file "blazer_ai.rb", "config/initializers/blazer_ai.rb"
      end

      def copy_ruby_llm_initializer
        return if ruby_llm_configured?

        copy_file "ruby_llm.rb", "config/initializers/ruby_llm.rb"
      end

      private

      def ruby_llm_configured?
        initializers_path = File.join(destination_root, "config/initializers")
        return false unless File.directory?(initializers_path)

        Dir.glob(File.join(initializers_path, "*.rb")).any? do |file|
          File.read(file).include?("RubyLLM.configure")
        end
      end
    end
  end
end
