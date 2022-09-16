# frozen_string_literal: true

module V1
  class SessionsController < V1::BaseController
    skip_before_action :authenticate!
    before_action :find_user, only: [:create]

    def create
      payload = { user_id: @user.id,
                  access_token: permitted_params[:access_token],
                  email: permitted_params[:email] }
      token = JsonWebToken.encode(payload)
      render_json(
          message: I18n.t('login.success'),
          data: { auth_token: token }
          status: :ok
        )
    end

    private

    def permitted_params
      params.require(:user).permit(:email, :access_token)
    end

    def find_user
      @user = User.find_or_create_by(email: permitted_params[:email])
      return true if @user

      render_json(
        message: I18n.t('errors.record', model_name: 'User'),
        status: :unauthorized
      )
    end
  end
end
