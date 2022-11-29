module Api::V1
  class UsersController < ApplicationController
    def update
      result = Users::V1::Update.new(user_update_params, params[:id]).call
      if result["status"]
        render json: { message: I18n.t('users.success.update') }
      else
        render json: { message: I18n.t('users.error.update'), errors: result["error_message"] },
              status: :unprocessable_entity
      end
    end

    private

    def user_update_params
      params.require(:user).permit(:role, :department_id)
    end
  end
end
