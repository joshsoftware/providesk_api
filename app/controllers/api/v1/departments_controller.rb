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
      if(current_user.organization_id.eql?(params[:organization_id].to_i))
        department = Department.where(id: params[:department_id]).last
        render json: { message: "Department not found"}, status: :unprocessable_entity and return if department.nil?
        if(department.organization_id.eql?(params[:organization_id].to_i))
          categories = Category.where(department_id: params[:department_id].to_i)
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
            message: "Entered organization does not have specified department"
          }, status: 400
        end
      else
        render json:{
          message: "User not registered to organization"
        }, status: 403
      end
    end
  end
end