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

    def show_categories
      department = Department.where(id: params[:department_id]).last
      render json: {message: I18n.t('department.error.invalid_department_id')}, status: :unprocessable_entity and return if department.nil?
      if(department.organization_id.eql?(current_user.organization_id))
        categories = Category.where(department_id: department.id)
        categories_list = []
        categories.each do |category|
          categories_list.push(
            {
              name: category.name,
              id: category.id
            }
          )     
        end
        render json:{
          data: {
            total: categories_list.length,
            categories: categories_list
          }
        }
      else
        render json:{
          message: I18n.t('organization.error.unauthorized_user')
        }, status: 403
      end
    end
  end
end
