require "test_helper"
require "rails/generators/test_case"
require "generators/blazer_ai/install_generator"

class InstallGeneratorTest < Rails::Generators::TestCase
  tests BlazerAi::Generators::InstallGenerator
  destination File.expand_path("../../tmp", __dir__)
  setup :prepare_destination

  test "generates initializer with default openai provider" do
    run_generator

    assert_file "config/initializers/blazer_ai.rb" do |content|
      assert_match(/Provider: openai/, content)
      assert_match(/config\.openai_api_key/, content)
      assert_match(/OPENAI_API_KEY/, content)
      assert_match(/gpt-5.1-codex/, content)
    end
  end

  test "generates initializer with anthropic provider" do
    run_generator [ "--provider=anthropic" ]

    assert_file "config/initializers/blazer_ai.rb" do |content|
      assert_match(/Provider: anthropic/, content)
      assert_match(/config\.anthropic_api_key/, content)
      assert_match(/ANTHROPIC_API_KEY/, content)
      assert_match(/claude-sonnet-4-20250514/, content)
    end
  end

  test "generates initializer with google provider" do
    run_generator [ "--provider=google" ]

    assert_file "config/initializers/blazer_ai.rb" do |content|
      assert_match(/Provider: google/, content)
      assert_match(/config\.gemini_api_key/, content)
      assert_match(/GEMINI_API_KEY/, content)
      assert_match(/gemini-2.0-flash/, content)
    end
  end

  test "falls back to openai for unknown provider" do
    run_generator [ "--provider=unknown" ]

    assert_file "config/initializers/blazer_ai.rb" do |content|
      assert_match(/config\.openai_api_key/, content)
    end
  end

  test "initializer includes blazer ai configuration" do
    run_generator

    assert_file "config/initializers/blazer_ai.rb" do |content|
      assert_match(/Blazer::Ai\.configure/, content)
      assert_match(/config\.default_model/, content)
      assert_match(/temperature/, content)
      assert_match(/rate_limit_per_minute/, content)
    end
  end
end
