# blazer-ai

AI-powered SQL generation for [Blazer](https://github.com/ankane/blazer) using [RubyLLM](https://github.com/crmne/ruby_llm).

Transform natural language descriptions into SQL queries with a single click. Supports multiple AI providers including OpenAI, Anthropic Claude, Google Gemini, and local models via Ollama.

## Features

- **Natural Language to SQL** - Describe your query in plain English
- **Multi-Provider Support** - OpenAI, Anthropic, Gemini, Bedrock, Ollama, and more
- **Schema-Aware** - Automatically injects your database schema for accurate queries
- **Safety First** - SQL validation prevents dangerous operations
- **Rate Limiting** - Built-in protection against API abuse
- **Multiple Data Sources** - Works with all Blazer data sources

## Installation

Add to your Gemfile:

```ruby
gem "blazer-ai"
```

```bash
bundle install
```

If Blazer isn't set up yet:

```bash
bin/rails blazer:install:migrations
bin/rails db:migrate
```

## Configuration

### 1. Configure RubyLLM

Create an initializer for your AI provider:

```ruby
# config/initializers/ruby_llm.rb

RubyLLM.configure do |c|
  # OpenAI
  c.openai_api_key = ENV["OPENAI_API_KEY"]

  # Anthropic Claude
  c.anthropic_api_key = ENV["ANTHROPIC_API_KEY"]

  # Google Gemini
  c.gemini_api_key = ENV["GEMINI_API_KEY"]

  # AWS Bedrock
  c.bedrock_api_key = ENV["AWS_ACCESS_KEY_ID"]
  c.bedrock_secret_key = ENV["AWS_SECRET_ACCESS_KEY"]
  c.bedrock_region = ENV["AWS_REGION"]

  # Local Ollama
  c.ollama_api_base = "http://localhost:11434/v1"
end
```

### 2. Configure Blazer AI (optional)

```ruby
# config/initializers/blazer_ai.rb

Blazer::Ai.configure do |c|
  # Enable/disable AI features (default: true)
  c.enabled = true

  # Default model (default: "o4-mini")
  c.default_model = "claude-sonnet-4-5-20250929"

  # Temperature for generation (default: 0.2)
  c.temperature = 0.2

  # Rate limiting (default: 20 requests/minute)
  c.rate_limit_per_minute = 20

  # Schema cache duration (default: 12 hours)
  c.schema_cache_ttl = 12.hours

  # Maximum prompt length (default: 2000 characters)
  c.max_prompt_length = 2000
end
```

## Usage

1. Visit `/blazer/queries/new`
2. Enter a query name like "Active Users"
3. Add a description: "Show all users who logged in within the last 7 days"
4. Click **Generate SQL (AI)**
5. Review and run the generated SQL

### Keyboard Shortcut

Press `Ctrl+Shift+G` (or `Cmd+Shift+G` on Mac) to generate SQL.

## Security

Blazer AI includes multiple security layers:

### SQL Validation

Generated SQL is validated before display:
- Only `SELECT` and `WITH` statements allowed
- Blocks `INSERT`, `UPDATE`, `DELETE`, `DROP`, `TRUNCATE`, etc.
- Detects SQL injection patterns
- Prevents multi-statement queries

### Prompt Sanitization

User input is sanitized to prevent prompt injection:
- Removes potential injection patterns
- Truncates overly long inputs
- Strips dangerous characters

### Rate Limiting

Built-in rate limiting prevents API abuse:
- Default: 20 requests per minute per user
- Configurable via `rate_limit_per_minute`
- Uses Rails cache for distributed limiting

### Best Practices

1. **Use a read-only database user** for Blazer connections
2. **Set appropriate row limits** in Blazer config
3. **Enable audit logging** to track generated queries
4. **Review generated SQL** before executing

## How It Works

```
User enters: "Show top 10 products by revenue"
                              |
                              v
+-------------------------------------------------------------+
|  1. Sanitize input (PromptSanitizer)                        |
|  2. Build schema context (SchemaCache)                      |
|  3. Generate SQL via LLM (RubyLLM)                          |
|  4. Validate output (SqlValidator)                          |
|  5. Return to editor                                        |
+-------------------------------------------------------------+
                              |
                              v
+-------------------------------------------------------------+
|  SELECT p.name, SUM(oi.quantity * oi.price) as revenue      |
|  FROM products p                                            |
|  JOIN order_items oi ON p.id = oi.product_id                |
|  GROUP BY p.id, p.name                                      |
|  ORDER BY revenue DESC                                      |
|  LIMIT 10;                                                  |
+-------------------------------------------------------------+
```

## API

### Configuration

```ruby
Blazer::Ai.configuration.enabled          # => true
Blazer::Ai.configuration.default_model    # => "o4-mini"
Blazer::Ai.configuration.temperature      # => 0.2
Blazer::Ai.configuration.rate_limit_per_minute # => 20
```

### Schema Cache

```ruby
# Invalidate schema cache for a data source
Blazer::Ai::SchemaCache.invalidate(data_source_id: "main")

# Invalidate all cached schemas
Blazer::Ai::SchemaCache.invalidate_all
```

### SQL Validation

```ruby
validator = Blazer::Ai::SqlValidator.new
validator.safe?("SELECT * FROM users")  # => true
validator.safe?("DROP TABLE users")      # => false
```

## Development

```bash
cd blazer-ai
bundle install
bin/rails test
```

Run the dummy app:

```bash
cd test/dummy
bin/rails db:create db:migrate
bin/rails server
```

## Requirements

- Ruby >= 3.2
- Rails >= 7.1
- Blazer >= 3.0
- RubyLLM >= 1.0

## License

MIT License. See [LICENSE](MIT-LICENSE) for details.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
