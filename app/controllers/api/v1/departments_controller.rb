# frozen_string_literal: true

module Api::V1
  class DepartmentsController < ApplicationController
    def create
      if params[:name].present? && params[:organization_id].present?
        result = Departments::V1::Create.new(params, current_user).call
        if result["status"]
          render json: { message: I18n.t('department.success.create') }
        else
          render json: { message: result["error_message"] } , status: :unprocessable_entity
        end
      else
        render json: { message: I18n.t('department.invalid_params')}, status: :unprocessable_entity
      end
    end

    def show_users
      result = Departments::V1::ShowUsers.new(params, current_user).call
      if result["status"]
        render json: { data: result["data"] }
      else
        if result["error"].eql?("no_department_found")
          render json: {message: I18n.t('department.error.invalid_department_id')}, status: :unprocessable_entity
        elsif result["error"].eql?("unauthorized_user")
          render json:{ message: I18n.t('organization.error.unauthorized_user')}, status: 403
        end
      end
    end
  end
end