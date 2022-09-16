# frozen_string_literal: true

module Api::V1
  class DepartmentsController < ApplicationController
    def create
      if params[:name].present?
        result = Departments::V1::Create.new(params).call
        if result.present?
          render json: { message: I18n.t('department.success.create') }
        else
          render json: { message: I18n.t('department.error.create')}, status: :unprocessable_entity
        end
      else
        render json: { message: I18n.t('department.invalid_params')}, status: :unprocessable_entity
      end
    end
  end
end