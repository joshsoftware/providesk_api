# frozen_string_literal: true

module Api::V1
  class DepartmentsController < ApplicationController
    def create
      if department_params[:name].present? && department_params[:organization_id].present?
        result = Departments::V1::Create.new(department_params).call
        if result["status"]
          render json: { message: I18n.t('department.success.create') }
        else
          render json: { message: result["error_message"] } , status: :unprocessable_entity
        end
      else
        render json: { message: I18n.t('department.error.invalid_params')}, status: :unprocessable_entity
      end
    end

    def users
      result = Departments::V1::Users.new(params).call
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
    
    def categories
      result = Departments::V1::Categories.new(params).call
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

    private

    def department_params
      params.require(:department).permit(:name, :organization_id)
    end
  end
end
