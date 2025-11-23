# Configuration for Blazer AI.
class Blazer::Ai::Configuration
  attr_accessor :enabled, :default_model, :temperature, :rate_limit_per_minute,
                :schema_cache_ttl, :max_prompt_length, :max_sql_length

  def initialize
    @enabled = true
    @default_model = "gpt-4o-mini"
    @temperature = 0.2
    @rate_limit_per_minute = 20
    @schema_cache_ttl = 12.hours
    @max_prompt_length = 2000
    @max_sql_length = 10_000
  end

  def enabled?
    @enabled
  end
end
