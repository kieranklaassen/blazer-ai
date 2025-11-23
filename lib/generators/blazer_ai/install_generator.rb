require "rails/generators"

module BlazerAi
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.join(__dir__, "templates")

      class_option :provider, type: :string, default: "openai",
        desc: "LLM provider to use (openai, anthropic, google)"

      def copy_initializer
        @provider = options[:provider].to_s.downcase
        unless %w[openai anthropic google].include?(@provider)
          say_status :error, "Unknown provider: #{@provider}. Using openai.", :red
          @provider = "openai"
        end

        @model = default_model
        @env_var = env_var_name

        template "initializer.rb", "config/initializers/blazer_ai.rb"
      end

      def show_post_install
        say ""
        say "Blazer AI installed!", :green
        say ""
        say "Next steps:"
        say "  1. Set your API key:"
        say "     export #{@env_var}=your_api_key_here"
        say ""
        say "  2. Restart your Rails server"
        say ""
        say "Routes are automatically added to Blazer. No manual mounting required."
        say ""
      end

      private

      def default_model
        case @provider
        when "openai" then "gpt-4o-mini"
        when "anthropic" then "claude-sonnet-4-20250514"
        when "google" then "gemini-1.5-flash"
        end
      end

      def env_var_name
        case @provider
        when "openai" then "OPENAI_API_KEY"
        when "anthropic" then "ANTHROPIC_API_KEY"
        when "google" then "GEMINI_API_KEY"
        end
      end
    end
  end
end
