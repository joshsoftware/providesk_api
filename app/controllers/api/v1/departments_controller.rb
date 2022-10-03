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
        render json: { message: I18n.t('department.error.invalid_params')}, status: :unprocessable_entity
      end
    end
  end
end