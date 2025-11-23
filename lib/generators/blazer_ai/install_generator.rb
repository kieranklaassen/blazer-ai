require "rails/generators"

module BlazerAi
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.join(__dir__, "templates")

      class_option :provider, type: :string, default: "openai",
        desc: "LLM provider (openai, anthropic, google)"

      def check_blazer
        unless defined?(Blazer) || File.exist?("config/blazer.yml")
          say_status :warning, "Blazer not detected. Install Blazer first:", :yellow
          say "  gem 'blazer'"
          say "  rails generate blazer:install"
          say ""
        end
      end

      def check_existing_config
        if File.exist?("config/initializers/ruby_llm.rb")
          say_status :info, "Existing ruby_llm.rb found - will use that for API keys", :blue
          @existing_ruby_llm = true
        end
      end

      def copy_initializer
        @provider = options[:provider].to_s.downcase
        unless %w[openai anthropic google].include?(@provider)
          say_status :error, "Unknown provider: #{@provider}. Using openai.", :red
          @provider = "openai"
        end

        @model = default_model
        @env_var = env_var_name

        template "initializer.rb.tt", "config/initializers/blazer_ai.rb"
      end

      def show_post_install
        say ""
        say "Blazer AI installed!", :green
        say ""
        say "Set your API key:"
        say "  export #{@env_var}=your_key_here", :yellow
        say ""
        say "Then restart your Rails server and visit /blazer/queries/new"
        say ""
      end

      private

      def default_model
        case @provider
        when "openai" then "gpt-4o-mini"
        when "anthropic" then "claude-sonnet-4-20250514"
        when "google" then "gemini-2.0-flash"
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
