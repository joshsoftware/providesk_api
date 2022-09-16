# frozen_string_literal: true

module Api::V1
  class DepartmentsController < ApplicationController
    def create
      result = Departments::V1::Create.new(params).call
      if result.present?
        render json: { status: 200, message: I18n.t('department.success.create') }
      else
        render json: { message: I18n.t('department.error.create') }
      end
    end
  end
end