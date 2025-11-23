# Blazer AI

AI-powered SQL generation for [Blazer](https://github.com/ankane/blazer).

[![Build Status](https://github.com/kieranklaassen/blazer-ai/actions/workflows/build.yml/badge.svg)](https://github.com/kieranklaassen/blazer-ai/actions)

## Features

- Natural language to SQL generation
- Multi-provider support (OpenAI, Anthropic, Gemini)
- Schema-aware context for accurate queries
- SQL validation prevents dangerous operations
- Built-in rate limiting

## Installation

Add to your Gemfile:

```ruby
gem "blazer-ai"
```

Run:

```bash
bundle install
rails generate blazer_ai:install
```

Set your API key:

```bash
export OPENAI_API_KEY=your_key_here
```

Restart your server and visit `/blazer/queries/new`. Click **Generate SQL (AI)**.

That's it!

## Providers

The default provider is OpenAI. For other providers:

```bash
rails generate blazer_ai:install --provider=anthropic
```

```bash
rails generate blazer_ai:install --provider=google
```

Set the corresponding API key:

| Provider | Environment Variable |
|----------|---------------------|
| OpenAI | `OPENAI_API_KEY` |
| Anthropic | `ANTHROPIC_API_KEY` |
| Google | `GEMINI_API_KEY` |

## Configuration

The generator creates `config/initializers/blazer_ai.rb`:

```ruby
Blazer::Ai.configure do |config|
  config.default_model = "gpt-5.1-codex"
  # config.temperature = 0.2
  # config.rate_limit_per_minute = 20
  # config.schema_cache_ttl = 12.hours
end
```

## Usage

1. Visit `/blazer/queries/new`
2. Enter a description like "Show users who signed up this week"
3. Click **Generate SQL (AI)**
4. Review and run

Keyboard shortcut: `Ctrl+Shift+G` (or `Cmd+Shift+G` on Mac)

## Security

Generated SQL is validated:

- Only `SELECT` and `WITH` statements allowed
- Blocks `INSERT`, `UPDATE`, `DELETE`, `DROP`, `TRUNCATE`
- Detects SQL injection patterns

Best practices:

- Use a read-only database user for Blazer
- Review generated SQL before executing

## API

```ruby
# invalidate schema cache
Blazer::Ai::SchemaCache.invalidate(data_source_id: "main")
Blazer::Ai::SchemaCache.invalidate_all

# validate SQL
validator = Blazer::Ai::SqlValidator.new
validator.safe?("SELECT * FROM users")  # => true
```

## Development

```bash
bundle install
bundle exec rake test
```

## Requirements

- Ruby >= 3.2
- Rails >= 7.1
- Blazer >= 3.0

## License

MIT
