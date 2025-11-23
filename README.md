# Blazer AI

AI-powered SQL generation for [Blazer](https://github.com/ankane/blazer).

[![Gem Version](https://img.shields.io/gem/v/blazer-ai)](https://rubygems.org/gems/blazer-ai)
[![Build Status](https://github.com/<user>/blazer-ai/actions/workflows/build.yml/badge.svg)](https://github.com/<user>/blazer-ai/actions)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](MIT-LICENSE)

## Features

- Natural language to SQL generation
- Multi-provider support (OpenAI, Anthropic, Gemini, Bedrock, Ollama)
- Schema-aware context for accurate queries
- SQL validation prevents dangerous operations
- Built-in rate limiting

## Installation

Add this line to your application's **Gemfile**:

```ruby
gem "blazer-ai"
```

Run:

```bash
bundle install
```

## Quick Start

Run the install generator:

```bash
rails generate blazer_ai:install
```

Choose a provider:

```bash
rails generate blazer_ai:install --provider=openai
```

```bash
rails generate blazer_ai:install --provider=anthropic
```

```bash
rails generate blazer_ai:install --provider=google
```

The default provider is OpenAI.

## Configuration

### AI Provider

Create an initializer for your AI provider:

```ruby
# config/initializers/ruby_llm.rb
RubyLLM.configure do |c|
  c.openai_api_key = ENV["OPENAI_API_KEY"]
end
```

For Anthropic:

```ruby
RubyLLM.configure do |c|
  c.anthropic_api_key = ENV["ANTHROPIC_API_KEY"]
end
```

For Google Gemini:

```ruby
RubyLLM.configure do |c|
  c.gemini_api_key = ENV["GEMINI_API_KEY"]
end
```

### Blazer AI Options

```ruby
# config/initializers/blazer_ai.rb
Blazer::Ai.configure do |c|
  c.enabled = true                    # enable/disable AI features
  c.default_model = "gpt-4o-mini"     # model to use
  c.temperature = 0.2                 # generation temperature
  c.rate_limit_per_minute = 20        # requests per minute
  c.schema_cache_ttl = 12.hours       # schema cache duration
  c.max_prompt_length = 2000          # max input length
end
```

## Usage

1. Visit `/blazer/queries/new`
2. Enter a description like "Show users who logged in this week"
3. Click **Generate SQL (AI)**
4. Review and run the generated SQL

### Keyboard Shortcut

Press `Ctrl+Shift+G` (or `Cmd+Shift+G` on Mac) to generate SQL.

## Security

### SQL Validation

Generated SQL is validated before display:

- Only `SELECT` and `WITH` statements allowed
- Blocks `INSERT`, `UPDATE`, `DELETE`, `DROP`, `TRUNCATE`
- Detects SQL injection patterns
- Prevents multi-statement queries

### Best Practices

- Use a read-only database user for Blazer
- Set appropriate row limits in Blazer config
- Review generated SQL before executing

## API

### Schema Cache

```ruby
# invalidate schema cache for a data source
Blazer::Ai::SchemaCache.invalidate(data_source_id: "main")

# invalidate all cached schemas
Blazer::Ai::SchemaCache.invalidate_all
```

### SQL Validation

```ruby
validator = Blazer::Ai::SqlValidator.new
validator.safe?("SELECT * FROM users")  # => true
validator.safe?("DROP TABLE users")     # => false
```

## Development

```bash
bundle install
bundle exec rake test
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

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

MIT
