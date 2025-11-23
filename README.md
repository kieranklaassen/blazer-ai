# Blazer AI

AI-powered SQL generation for [Blazer](https://github.com/ankane/blazer)

[![Gem Version](https://badge.fury.io/rb/blazer-ai.svg)](https://badge.fury.io/rb/blazer-ai)
[![CI](https://github.com/kieranklaassen/blazer-ai/actions/workflows/ci.yml/badge.svg)](https://github.com/kieranklaassen/blazer-ai/actions/workflows/ci.yml)

## Installation

Add this line to your application's Gemfile:

```ruby
gem "blazer-ai"
```

Run:

```sh
bundle install
rails generate blazer_ai:install
```

And set your API key:

```sh
export OPENAI_API_KEY=your_key_here
```

## Usage

Visit `/blazer/queries/new` and click **Generate SQL (AI)**.

Keyboard shortcut: `Cmd+Shift+G` (Mac) or `Ctrl+Shift+G`

## Configuration

```ruby
Blazer::Ai.configure do |config|
  config.default_model = "gpt-5.1-codex"
  config.temperature = 0.2
  config.rate_limit_per_minute = 20
end
```

For other providers, update the initializer:

```ruby
# Anthropic
RubyLLM.configure do |config|
  config.anthropic_api_key = ENV["ANTHROPIC_API_KEY"]
end

Blazer::Ai.configure do |config|
  config.default_model = "claude-sonnet-4-20250514"
end
```

```ruby
# Google
RubyLLM.configure do |config|
  config.gemini_api_key = ENV["GEMINI_API_KEY"]
end

Blazer::Ai.configure do |config|
  config.default_model = "gemini-2.0-flash"
end
```

## API

Invalidate schema cache:

```ruby
Blazer::Ai::SchemaCache.invalidate(data_source_id: "main")
```

Validate SQL:

```ruby
Blazer::Ai::SqlValidator.new.safe?("SELECT * FROM users")
```

## Security

Only `SELECT` and `WITH` statements are allowed. Use a read-only database user.

## Development

```sh
bundle install
bundle exec rake test
```

## License

MIT
