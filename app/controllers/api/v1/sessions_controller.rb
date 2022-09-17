# frozen_string_literal: true
module Api::V1
  class SessionsController < ApplicationController
    skip_before_action :authenticate
    before_action :find_or_create_user, only: [:create]

    def create
      payload = { user_id: @user.id,
                  name: permitted_params[:name],
                  email: permitted_params[:email],
                  google_user_id: permitted_params[:google_user_id]
                }
      token = JsonWebToken.encode(payload)
      render json: {
          message: I18n.t('login.success'),
          data: { 
            auth_token: token,
            role_id: @user.role_id 
          }
      }, status: :ok
    end

    private
    def permitted_params
      params.require(:user).permit(:email, :name, :google_user_id)
    end

    def find_or_create_user
      @user = User.find_or_initialize_by(email: permitted_params[:email])
      @user.assign_attributes({
        name: permitted_params[:name],
        email: permitted_params[:email],
      })

      begin
        @user.save! if @user.changed?
      rescue ActiveRecord::RecordInvalid 
        render json: {
          errors: @user.errors.full_messages.join(", ")
        }, status: 422
      end
    end
  end
end
