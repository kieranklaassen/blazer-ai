module Blazer::Ai
  module SchemaCache
    SCHEMA_VERSION = ENV.fetch("BLAZER_AI_SCHEMA_VERSION", 1).to_i

    class << self
      def fetch(connection, data_source_id: nil)
        cache_key = build_cache_key(data_source_id)
        ttl = Blazer::Ai.configuration.schema_cache_ttl

        Rails.cache.fetch(cache_key, expires_in: ttl) do
          build_schema_string(connection)
        end
      end

      def invalidate(data_source_id: nil)
        cache_key = build_cache_key(data_source_id)
        Rails.cache.delete(cache_key)
      end

      def invalidate_all
        # Pattern-based deletion if supported, otherwise noop
        if Rails.cache.respond_to?(:delete_matched)
          Rails.cache.delete_matched("blazer_ai:schema:*")
        end
      end

      private

      def build_cache_key(data_source_id)
        ds_part = data_source_id || "default"
        "blazer_ai:schema:v#{SCHEMA_VERSION}:#{ds_part}"
      end

      def build_schema_string(connection)
        tables = connection.tables.sort
        tables.map do |table_name|
          columns = connection.columns(table_name).map do |col|
            "#{col.name} (#{col.sql_type})"
          end
          "#{table_name}: #{columns.join(', ')}"
        end.join("\n")
      end
    end
  end
end
