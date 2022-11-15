module Api::V1
  class CategoriesController < ApplicationController
    def create
      begin
        result = Categories::V1::Create.new(categories_params, current_user).call
        if result[:status]
          render json: { message: I18n.t('categories.success.create') }
        else
          render json: { message: I18n.t('categories.error.create'), errors: result[:error_message]}, 
                status: :unprocessable_entity
        end
      rescue ActionController::ParameterMissing
        render json: { message: I18n.t('categories.error.invalid_params') }, 
              status: :unprocessable_entity 
      end
    end

    private 

    def categories_params
      params.require(:categories).permit(:name, :priority, :department_id) 
    end
  end
end
