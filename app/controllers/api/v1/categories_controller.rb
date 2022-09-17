module Api::V1
  class CategoriesController < ApplicationController
    def create
      result = Categories::V1::Create.new(categories_params, current_user).call
      if result["status"]
        render status: 200, json: { message: I18n.t('categories.success.create')}
      else
        render status: 422, json: { message: I18n.t('categories.error.create')}
      end
    end

    private 

    def categories_params
      params.require(:categories).permit(:name, :priority, :department_id)    
    end
  end
end
