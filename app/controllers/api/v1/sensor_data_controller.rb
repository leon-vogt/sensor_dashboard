class Api::V1::SensorDataController < ApplicationController
  include ApiKeyAuthenticatable

  # Deactivate Devise authentication
  skip_before_action :authenticate_user!

  # Deactivate CSRF protection, because we are using the API key for authentication
  skip_before_action :verify_authenticity_token

  # Check for valid API key, before any other action
  # If the API key is invalid, we will return a 401 Unauthorized response
  prepend_before_action :authenticate_with_api_key!


  def create
    NewSensorDataJob.perform_later(@current_device.id, sensor_value_params)
    render json: { status: 'success' }, status: :ok
  end

  private
  def sensor_value_params
    params.require(:sensor_values).permit!
  end
end
