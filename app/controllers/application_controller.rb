# frozen_string_literal: true

class ApplicationController < ActionController::API
  before_action :authenticate

  attr_reader :current_user, :payload

  # rescue_from ActionController::ParameterMissing, with: :params_missing

  rescue_from ActionController::ParameterMissing do |exception|
    render json: { errors: I18n.t('missing_params') }, status: :unprocessable_entity
  end

  rescue_from ActiveRecord::RecordNotFound do |exception|
    render json: { errors: I18n.t('record_not_found') }, status: 404
  end

  rescue_from CanCan::AccessDenied do |exception|
    render json: { message: exception.message, authorization_failure: true }, status: :unauthorized
  end

  def params_missing
    render json: { message: I18n.t('organizations.error.invalid_params') }, 
            status: :unprocessable_entity
  end

  def render_json(message:, data: {}, status_code: :ok)
    return render(json: { message: message, data: data }, status: status_code)
  end

  def validate_jwt_token
    false unless request.headers['Authorization'].present?
    token = request.headers['Authorization']
    JsonWebToken.decode(token)
  end

  def authenticate
    is_valid_jwt = validate_jwt_token
    if(is_valid_jwt)
      load_current_user(is_valid_jwt)
    else
      return token_invalid
    end
    token_invalid unless @current_user
  end

  def token_invalid
    render_json(message: I18n.t('session.expired'), status_code: :unauthorized)
  end

  def load_current_user(payload)
    @current_user = User.find_by(id: payload['user_id'])
  end

  def serialize_resource(resources, serializer, root = nil, extra = {} )
    opts = { each_serializer: serializer, root: root }.merge(extra)
    ActiveModelSerializers::SerializableResource.new(resources, opts) if resources
  end
end