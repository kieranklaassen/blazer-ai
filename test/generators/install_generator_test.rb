require "test_helper"
require "rails/generators/test_case"
require "generators/blazer_ai/install_generator"

class InstallGeneratorTest < Rails::Generators::TestCase
  tests BlazerAi::Generators::InstallGenerator
  destination File.expand_path("../../tmp", __dir__)
  setup :prepare_destination

  def test_creates_blazer_ai_initializer
    run_generator

    assert_file "config/initializers/blazer_ai.rb" do |content|
      assert_match(/Blazer::Ai\.configure/, content)
      assert_match(/default_model/, content)
    end
  end

  def test_blazer_ai_initializer_does_not_contain_ruby_llm_config
    run_generator

    assert_file "config/initializers/blazer_ai.rb" do |content|
      refute_match(/RubyLLM\.configure/, content)
    end
  end

  def test_creates_ruby_llm_initializer_when_not_exists
    run_generator

    assert_file "config/initializers/ruby_llm.rb" do |content|
      assert_match(/RubyLLM\.configure/, content)
      assert_match(/openai_api_key/, content)
    end
  end

  def test_skips_ruby_llm_initializer_when_already_exists
    # Pre-create the ruby_llm.rb initializer
    FileUtils.mkdir_p(File.join(destination_root, "config/initializers"))
    File.write(
      File.join(destination_root, "config/initializers/ruby_llm.rb"),
      "# Existing RubyLLM config\nRubyLLM.configure { |c| c.openai_api_key = 'existing' }\n"
    )

    run_generator

    # Original content should be preserved (not overwritten)
    assert_file "config/initializers/ruby_llm.rb" do |content|
      assert_match(/existing/, content)
      refute_match(/ENV\["OPENAI_API_KEY"\]/, content)
    end
  end

  def test_skips_ruby_llm_when_config_exists_in_any_initializer
    # Pre-create some other initializer that contains RubyLLM.configure
    FileUtils.mkdir_p(File.join(destination_root, "config/initializers"))
    File.write(
      File.join(destination_root, "config/initializers/llm_setup.rb"),
      "RubyLLM.configure do |config|\n  config.openai_api_key = ENV['OPENAI_API_KEY']\nend\n"
    )

    run_generator

    # Should not create ruby_llm.rb since config exists elsewhere
    assert_no_file "config/initializers/ruby_llm.rb"
  end

  def test_identical_on_second_run
    run_generator
    output = run_generator

    assert_match(/identical/, output)
  end
end
