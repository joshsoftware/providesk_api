module Api::V1
  class CategoriesController < ApplicationController
    def create
      result = Categories::V1::Create.new(categories_params, current_user).call
      byebug
      if result[:status]
        render json: { message: I18n.t('categories.success.create') }
      else
        render json: { message: I18n.t('categories.error.create') }, status: :unprocessable_entity
      end
    end

    private 

    def categories_params
      params.require(:categories).permit(:name, :priority, :department_id)    
    end
  end
end
