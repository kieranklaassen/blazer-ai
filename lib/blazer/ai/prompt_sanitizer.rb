module Blazer
  module Ai
    class PromptSanitizer
      # Patterns that might indicate prompt injection attempts
      SUSPICIOUS_PATTERNS = [
        /ignore\s+(previous|above|all)\s+instructions/i,
        /disregard\s+(previous|above|all)/i,
        /forget\s+(everything|what|your)/i,
        /new\s+instructions?:/i,
        /system\s*:/i,
        /assistant\s*:/i,
        /\bDROP\b/i,
        /\bDELETE\b/i,
        /\bTRUNCATE\b/i,
        /<script/i,
        /javascript:/i,
      ].freeze

      def initialize(max_length: nil)
        @max_length = max_length || Blazer::Ai.configuration.max_prompt_length
      end

      def sanitize(prompt)
        return "" if prompt.blank?

        sanitized = prompt.to_s.strip

        # Truncate to max length
        sanitized = sanitized[0...@max_length]

        # Remove potential injection patterns (replace with empty string)
        SUSPICIOUS_PATTERNS.each do |pattern|
          sanitized = sanitized.gsub(pattern, "")
        end

        # Remove angle brackets that might affect prompt parsing
        sanitized = sanitized.gsub(/[<>]/, "")

        sanitized.strip
      end

      def suspicious?(prompt)
        return false if prompt.blank?
        SUSPICIOUS_PATTERNS.any? { |p| prompt.match?(p) }
      end
    end
  end
end
