# frozen_string_literal: true

module Api::V1
  class CategoriesController < ApplicationController
    def create
      result = Categories::V1::Create.new(category_params).call
      if result[:status]
        render json: { message: I18n.t('categories.success.create') }
      else
        render json: { message: I18n.t('categories.error.create'), errors: result[:error_message]}, 
              status: :unprocessable_entity
      end
    end

    private 

    def category_params
      params.require(:category).permit(:name, :priority, :department_id, :sla_unit, :sla_duration_type) 
    end
  end
end
