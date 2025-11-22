module Blazer::Ai
  class SqlGenerator
    class GenerationError < StandardError; end

    def initialize(params:, data_source: nil)
      @name = params[:name].to_s.strip
      @description = params[:description].to_s.strip
      @data_source = data_source || default_data_source
      @sanitizer = PromptSanitizer.new
      @validator = SqlValidator.new
    end

    def call
      validate_input!
      sanitize_input!

      schema = build_schema_context
      adapter_name = determine_adapter_name

      response = generate_sql(schema, adapter_name)
      sql = @validator.extract_clean_sql(response)

      raise GenerationError, "Failed to generate valid SQL" if sql.blank?

      @validator.validate!(sql)
      sql
    end

    private

    def validate_input!
      if @name.blank? && @description.blank?
        raise GenerationError, "Please provide a name or description for the query"
      end
    end

    def sanitize_input!
      @name = @sanitizer.sanitize(@name)
      @description = @sanitizer.sanitize(@description)
    end

    def build_schema_context
      connection = data_source_connection
      SchemaCache.fetch(connection, data_source_id: @data_source&.id)
    end

    def determine_adapter_name
      if @data_source
        @data_source.adapter.to_s.downcase
      else
        data_source_connection.adapter_name.downcase
      end
    end

    def data_source_connection
      if @data_source && @data_source.respond_to?(:connection)
        @data_source.connection
      else
        ActiveRecord::Base.connection
      end
    end

    def default_data_source
      return nil unless defined?(Blazer) && Blazer.respond_to?(:data_sources)
      Blazer.data_sources.values.first
    end

    def generate_sql(schema, adapter_name)
      prompt = build_prompt(schema, adapter_name)
      model = Blazer::Ai.configuration.default_model
      temperature = Blazer::Ai.configuration.temperature

      # Timeout to prevent hung requests if LLM provider is slow/unresponsive
      Timeout.timeout(30, GenerationError, "SQL generation timed out. Please try again.") do
        RubyLLM.chat(model: model)
               .with_temperature(temperature)
               .ask(prompt)
               .content
      end
    end

    def build_prompt(schema, adapter_name)
      <<~PROMPT
        You are an expert SQL analyst generating queries for a data exploration tool.

        CRITICAL RULES:
        1. Generate ONLY SELECT or WITH...SELECT queries
        2. NEVER use INSERT, UPDATE, DELETE, DROP, ALTER, TRUNCATE, GRANT, REVOKE, EXEC, EXECUTE, or UNION
        3. Use only tables and columns from the schema below
        4. Always include a LIMIT clause (max 10000 rows)
        5. Use table aliases for readability
        6. Handle NULL values appropriately with COALESCE or IS NULL checks
        7. Return ONLY the SQL query - no explanations, no markdown formatting, no code blocks

        DATABASE TYPE: #{adapter_name}

        SCHEMA:
        #{schema}

        USER REQUEST:
        Name: #{@name}
        Description: #{@description}

        Generate the SQL query now:
      PROMPT
    end
  end
end