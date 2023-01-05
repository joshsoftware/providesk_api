# frozen_string_literal: true
module Api::V1
  class SessionsController < ApplicationController
    skip_before_action :authenticate
    skip_load_and_authorize_resource
    
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
            role: @user.role.name,
            organizations: get_organization_list
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
        email: permitted_params[:email]
      })
      @user.role_id = params[:user][:role_id] if params[:user][:role_id].present?

      begin
        @user.save! if @user.changed?
      rescue ActiveRecord::RecordInvalid 
        render json: {
          errors: @user.errors.full_messages.join(", ")
        }, status: 422
      end
    end

    def get_organization_list
      if @user.is_super_admin?
        organization_list = Organization.all.select(:id, :name).order(id: :asc)
      elsif @user.is_admin?
        organization_list = ["id": @user.organization_id, "name": @user.organization.name]
      elsif @user.is_department_head? || @user.is_resolver?
        organization_list = [{ "id": @user.organization.id,
                               "name": @user.organization.name, 
                               "department_id": @user.department.id, 
                               "department_name": @user.department.name }]
      else
        organization_list = ["id": @user.organization_id, "name": @user.organization.name]
      end
    end
  end
end
