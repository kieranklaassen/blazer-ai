require "test_helper"

class Blazer::Ai::RateLimiterTest < ActiveSupport::TestCase
  def setup
    @limiter = Blazer::Ai::RateLimiter.new(max_requests: 3, window: 1.minute)
    Rails.cache.clear
  end

  def test_allows_requests_under_limit
    assert_equal 1, @limiter.check_and_track!(identifier: "user_1")
    assert_equal 2, @limiter.check_and_track!(identifier: "user_1")
    assert_equal 3, @limiter.check_and_track!(identifier: "user_1")
  end

  def test_raises_when_limit_exceeded
    3.times { @limiter.check_and_track!(identifier: "user_2") }

    error = assert_raises(Blazer::Ai::RateLimiter::RateLimitExceeded) do
      @limiter.check_and_track!(identifier: "user_2")
    end

    assert_equal 60, error.retry_after
  end

  def test_separate_limits_per_identifier
    3.times { @limiter.check_and_track!(identifier: "user_a") }

    assert_equal 1, @limiter.check_and_track!(identifier: "user_b")
  end
end
