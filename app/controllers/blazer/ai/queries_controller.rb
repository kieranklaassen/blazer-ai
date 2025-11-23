# Handles AI-powered SQL generation requests.
# Validates rate limits, sanitizes input, and returns generated SQL.
class Blazer::Ai::QueriesController < Blazer::Ai::ApplicationController
  before_action :ensure_ai_enabled, only: [:create]

  def create
    rate_limiter.check_and_track!(identifier: current_identifier)

    data_source = find_data_source
    generator = SqlGenerator.new(params: query_params, data_source: data_source)

    sql = generator.call
    log_generation(query_params, sql)

    render json: {sql: sql}
  rescue SqlValidator::ValidationError
    render json: {error: "Generated SQL failed safety validation"}, status: :unprocessable_entity
  rescue SqlGenerator::GenerationError => e
    render json: {error: e.message}, status: :unprocessable_entity
  rescue RateLimiter::RateLimitExceeded => e
    render json: {error: e.message, retry_after: e.retry_after}, status: :too_many_requests
  rescue => e
    Rails.logger.error("[BlazerAI] Generation error: #{e.class}: #{e.message}")
    Rails.logger.error(e.backtrace.first(10).join("\n")) if e.backtrace
    render json: {error: "An error occurred while generating SQL. Please try again."}, status: :unprocessable_entity
  end

  private

  def query_params
    params.require(:query).permit(:name, :description, :data_source)
  end

  def find_data_source
    data_source_id = params.dig(:query, :data_source)
    return nil if data_source_id.blank?
    return nil unless defined?(Blazer) && Blazer.respond_to?(:data_sources)

    ds = Blazer.data_sources[data_source_id]
    return nil unless ds
    return nil unless data_source_authorized?(ds)

    ds
  end

  # Check if current user can access the data source (respects Blazer permissions)
  def data_source_authorized?(data_source)
    return true unless data_source.respond_to?(:settings)

    allowed_roles = data_source.settings["roles"]
    return true if allowed_roles.blank?

    user = respond_to?(:blazer_user, true) ? blazer_user : nil
    return false unless user

    user_roles = user.respond_to?(:roles) ? user.roles : []
    (allowed_roles & user_roles).any?
  end

  def ensure_ai_enabled
    render json: {error: "AI features are disabled"}, status: :forbidden unless Blazer::Ai.configuration.enabled?
  end

  def rate_limiter
    @rate_limiter ||= RateLimiter.new
  end

  def current_identifier
    if respond_to?(:blazer_user, true) && blazer_user
      user_id = blazer_user.respond_to?(:id) ? blazer_user.id : blazer_user.to_s
      "user:#{user_id}"
    else
      "ip:#{request.remote_ip}"
    end
  end

  def log_generation(query_params, sql)
    return unless Rails.logger

    Rails.logger.info("[BlazerAI] SQL generated for #{current_identifier}")
    Rails.logger.debug("[BlazerAI] Name: #{query_params[:name].to_s.truncate(100)}")
    Rails.logger.debug("[BlazerAI] Description: #{query_params[:description].to_s.truncate(200)}")
    Rails.logger.debug("[BlazerAI] SQL: #{sql.truncate(500)}")
  end
end
