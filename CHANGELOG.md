# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2025-11-22

### Added

- Initial release
- AI-powered SQL generation using RubyLLM
- Multi-provider support (OpenAI, Anthropic, Gemini, Bedrock, Ollama)
- Automatic database schema injection
- SQL validation to prevent dangerous operations
- Prompt sanitization to prevent injection attacks
- Rate limiting with configurable limits
- Support for multiple Blazer data sources
- Keyboard shortcut (Ctrl+Shift+G) for quick generation
- Loading states and error handling in the UI
- Comprehensive configuration options

### Security

- SqlValidator blocks INSERT, UPDATE, DELETE, DROP, TRUNCATE, etc.
- Detects SQL injection patterns and multi-statement queries
- PromptSanitizer removes potential prompt injection attempts
- RateLimiter prevents API abuse
