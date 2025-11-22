module Blazer
  module Ai
    class SqlValidator
      class ValidationError < StandardError; end

      # Keywords that indicate write/dangerous operations - never allow these
      FORBIDDEN_KEYWORDS = %w[
        INSERT UPDATE DELETE DROP TRUNCATE ALTER CREATE
        GRANT REVOKE COMMIT ROLLBACK SAVEPOINT LOCK
        EXEC EXECUTE CALL
        UNION
        COPY
        DECLARE SET
        PREPARE DEALLOCATE
        ATTACH DETACH
      ].freeze

      # Patterns that indicate potential SQL injection or dangerous operations
      DANGEROUS_PATTERNS = [
        /;\s*\w/i,                   # Multiple statements
        /--/,                        # SQL comments (potential injection)
        /\/\*/,                      # Block comments
        /#(?!\{)/,                   # MySQL comments (but not Ruby interpolation)
        /\$\$/,                      # PostgreSQL dollar quoting
        /INTO\s+OUTFILE/i,           # File operations
        /INTO\s+DUMPFILE/i,          # File operations
        /LOAD_FILE/i,                # File operations
        /LOAD\s+DATA/i,              # MySQL file loading
        /SLEEP\s*\(/i,               # Time-based attacks
        /BENCHMARK\s*\(/i,           # Time-based attacks
        /WAITFOR\s+DELAY/i,          # SQL Server time attack
        /PG_SLEEP/i,                 # PostgreSQL time attack
        /PG_READ_FILE/i,             # PostgreSQL file read
        /PG_LS_DIR/i,                # PostgreSQL directory listing
        /UTL_FILE/i,                 # Oracle file operations
        /DBMS_/i,                    # Oracle packages
        /XP_CMDSHELL/i,              # SQL Server command execution
        /SP_CONFIGURE/i,             # SQL Server configuration
        /0x[0-9A-Fa-f]{8,}/i,        # Long hex strings (potential encoding attacks)
      ].freeze

      def validate!(sql)
        raise ValidationError, "SQL cannot be empty" if sql.blank?

        # Normalize Unicode to prevent homoglyph attacks (e.g., Cyrillic characters)
        # and strip non-ASCII from keyword matching
        ascii_only = sql.encode("ASCII", undef: :replace, replace: "").upcase.gsub(/\s+/, " ")
        normalized = sql.upcase.gsub(/\s+/, " ")

        # Check for forbidden keywords (check both normalized and ASCII-only versions)
        FORBIDDEN_KEYWORDS.each do |keyword|
          if normalized.match?(/\b#{keyword}\b/) || ascii_only.match?(/\b#{keyword}\b/)
            raise ValidationError, "SQL contains forbidden keyword: #{keyword}"
          end
        end

        # Check for dangerous patterns
        DANGEROUS_PATTERNS.each do |pattern|
          if sql.match?(pattern)
            raise ValidationError, "SQL contains potentially dangerous pattern"
          end
        end

        # Ensure it starts with SELECT or WITH
        unless normalized.match?(/^\s*(SELECT|WITH)\b/)
          raise ValidationError, "SQL must start with SELECT or WITH"
        end

        true
      end

      def safe?(sql)
        validate!(sql)
        true
      rescue ValidationError
        false
      end

      def extract_clean_sql(content)
        return nil if content.blank?

        # Try to extract SQL from markdown code blocks
        if content.include?("```")
          match = content.match(/```(?:sql)?\s*\n?(.*?)\n?```/m)
          return match[1].strip if match
        end

        # Otherwise return the content stripped
        content.strip
      end
    end
  end
end
