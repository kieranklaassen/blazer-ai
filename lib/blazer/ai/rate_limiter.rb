module Blazer
  module Ai
    class RateLimiter
      class RateLimitExceeded < StandardError
        attr_reader :retry_after

        def initialize(message = "Rate limit exceeded", retry_after: 60)
          @retry_after = retry_after
          super(message)
        end
      end

      def initialize(cache: Rails.cache, max_requests: nil, window: 1.minute)
        @cache = cache
        @max_requests = max_requests || Blazer::Ai.configuration.rate_limit_per_minute
        @window = window
      end

      # Atomically increment and check rate limit in one operation
      # This prevents race conditions where concurrent requests bypass the limit
      def check_and_track!(identifier:)
        key = rate_limit_key(identifier)

        # Use atomic increment - most cache stores support this
        # For stores that don't support increment with initial value,
        # we fall back to a best-effort approach
        count = atomic_increment(key)

        if count > @max_requests
          raise RateLimitExceeded.new(
            "Rate limit exceeded. Please wait before generating more queries.",
            retry_after: @window.to_i
          )
        end

        count
      end

      private

      def atomic_increment(key)
        # Try to use atomic increment if available
        # Rails.cache.increment returns the new value after incrementing
        result = @cache.increment(key, 1, expires_in: @window)

        # Some cache stores return nil on first increment, handle that case
        if result.nil?
          @cache.write(key, 1, expires_in: @window)
          1
        else
          result
        end
      end

      def rate_limit_key(identifier)
        window_id = Time.current.to_i / @window.to_i
        "blazer_ai:rate_limit:#{identifier}:#{window_id}"
      end
    end
  end
end
