require "test_helper"

class Blazer::AiTest < ActiveSupport::TestCase
  def test_version
    assert Blazer::Ai::VERSION
  end

  def test_configuration
    assert Blazer::Ai.configuration
    assert_equal true, Blazer::Ai.configuration.enabled?
  end

  def test_configure
    original = Blazer::Ai.configuration.temperature

    Blazer::Ai.configure do |config|
      config.temperature = 0.5
    end

    assert_equal 0.5, Blazer::Ai.configuration.temperature

    Blazer::Ai.configure do |config|
      config.temperature = original
    end
  end
end
