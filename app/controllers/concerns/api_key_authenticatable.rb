module ApiKeyAuthenticatable
  extend ActiveSupport::Concern

  include ActionController::HttpAuthentication::Basic::ControllerMethods
  include ActionController::HttpAuthentication::Token::ControllerMethods

  attr_reader :current_device

  # Raises an error and automatically respond with a 401 HTTP status
  # when API key authentication fails
  def authenticate_with_api_key!
    authenticate_or_request_with_http_token(&method(:authenticator))
  end

  private
  attr_writer :current_device

  def authenticator(token, options)
    @current_device = AccessTokenHandler.new.authorize_by_token(token)
  end
end
