module Blazer
  module Ai
    class Configuration
      attr_accessor :enabled
      attr_accessor :default_model
      attr_accessor :temperature
      attr_accessor :rate_limit_per_minute
      attr_accessor :schema_cache_ttl
      attr_accessor :max_prompt_length
      attr_accessor :max_sql_length
      attr_accessor :blazer_mount_path

      def initialize
        @enabled = true
        @default_model = "o4-mini"
        @temperature = 0.2
        @rate_limit_per_minute = 20
        @schema_cache_ttl = 12.hours
        @max_prompt_length = 2000
        @max_sql_length = 10_000
        @blazer_mount_path = "/blazer"
      end

      def enabled?
        @enabled
      end

      # Returns the full path to the AI generate endpoint
      def generate_sql_path
        "#{blazer_mount_path.chomp('/')}/ai/generate_sql"
      end
    end
  end
end
