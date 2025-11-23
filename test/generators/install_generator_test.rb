require "test_helper"
require "rails/generators/test_case"
require "generators/blazer_ai/install_generator"

class InstallGeneratorTest < Rails::Generators::TestCase
  tests BlazerAi::Generators::InstallGenerator
  destination File.expand_path("../../tmp", __dir__)
  setup :prepare_destination

  def test_creates_initializer
    run_generator

    assert_file "config/initializers/blazer_ai.rb" do |content|
      assert_match(/RubyLLM\.configure/, content)
      assert_match(/openai_api_key/, content)
      assert_match(/Blazer::Ai\.configure/, content)
      assert_match(/default_model/, content)
    end
  end

  def test_identical_on_second_run
    run_generator
    output = run_generator

    assert_match(/identical/, output)
  end
end
