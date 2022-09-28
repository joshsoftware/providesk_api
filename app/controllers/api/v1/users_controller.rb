module Api::V1
  class UsersController < ApplicationController
    def create
      user = Users::V1::Create.new(user_params).call
      if user[:status]
        render json: { message: I18n.t('users.success.create') }
      else
        render json: { message: I18n.t('users.error.create') }, status: :unprocessable_entity
      end
    end

    def show
      user = Users::V1::Show.new(params[:id]).call
      if user[:status]
        render json: user, status: :ok
      else
        render json: {message: I18n.t('users.error.show')}, status: :unprocessable_entity
      end
    end

    def update
      user_new_data = Users::V1::Update.new(user_params, current_user, params[:id]).call
      if user_new_data[:status]
        render json: {message: I18n.t('users.success.update')}, status: 200
      else
        render json: {message: I18n.t('users.error.update')}, status: :unprocessable_entity
      end
    end

    def destroy
      user = Users::V1::Destroy.new(params[:id]).call
      if user[:status]
        render json: { message: I18n.t('users.success.destroy'), status: true }, status: :ok
      else
        render json: { message: I18n.t('users.error.destroy'), status: false }, status: :unprocessable_entity
      end
    end

    private

    def user_params
      params.require(:user_data).permit(:name, 
                                        :email, 
                                        :role_id, 
                                        :organization_id,
                                        :department_id)
    end
  end
end
