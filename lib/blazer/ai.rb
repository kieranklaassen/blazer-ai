require "blazer/ai/version"
require "blazer/ai/configuration"
require "blazer/ai/url_helper"

# Load security components
require "blazer/ai/sql_validator"
require "blazer/ai/prompt_sanitizer"
require "blazer/ai/rate_limiter"

# Load schema and SQL generators
require "blazer/ai/schema_cache"
require "blazer/ai/sql_generator"

# Load railtie last - it will load the engine
require "blazer/ai/railtie"

module Blazer
  module Ai
    class << self
      def configuration
        @configuration ||= Configuration.new
      end

      def configure
        yield(configuration)
      end

      def reset_configuration!
        @configuration = Configuration.new
      end
    end
  end
end
