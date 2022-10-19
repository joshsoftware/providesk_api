module Api::V1
  class OrganizationsController < ApplicationController

    def create
      begin
        result = Organizations::V1::Create.new(organization_params, current_user).call
        if result[:status]
          render json: { message: I18n.t('organizations.success.create') }
        else
          render json: { message: I18n.t('organizations.error.create'), 
                        errors: result[:error_message] }, 
                status: :unprocessable_entity
        end
      rescue ActionController::ParameterMissing
        render json: { message: I18n.t('organizations.error.invalid_params') }, 
              status: :unprocessable_entity
      end
    end

    def departments
      result = Organizations::V1::Departments.new(params, current_user).call
      if result["status"]
        render json: { data: result["data"] }
      else
        if result["error"].eql?("no_organization_found")
          render json: {message: I18n.t('organization.error.invalid_organization_id')}, status: :unprocessable_entity
        elsif result["error"].eql?("unauthorized_user")
          render json:{ message: I18n.t('organization.error.unauthorized_user')}, status: 403
        end
      end
    end
    private

    def organization_params
      params.require(:organization).permit(:name, domain: [])
    end
     
  end
end
