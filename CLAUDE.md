# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build and Test Commands
- Install dependencies: `bundle install`
- Run all tests: `bin/rails test`
- Run a specific test: `bin/rails test TEST=test/path/to/test_file.rb:LINE_NUMBER`
- Run the lint checks: `bundle exec rubocop`
- Start the development server: `bin/rails s`

## Code Style Guidelines
- Ruby styling follows Rails Omakase conventions with RuboCop
- Use 2 spaces for indentation
- Follow Ruby naming conventions: snake_case for methods/variables, CamelCase for classes
- Group imports by standard library, gems, and local modules with a blank line between groups
- Prefer `&&` and `||` over `and` and `or` operators
- Use meaningful variable names and keep methods short and focused
- Include proper error handling with specific exceptions
- Document public APIs with comments
- Follow Rails conventions for controllers, models, and views
- Keep code DRY (Don't Repeat Yourself)
- Write tests for all new functionality