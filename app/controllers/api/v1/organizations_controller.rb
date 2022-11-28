module Api::V1
  class OrganizationsController < ApplicationController
    load_and_authorize_resource

    def create
      result = Organizations::V1::Create.new(organization_params).call
      if result[:status]
        render json: { message: I18n.t('organizations.success.create') }
      else
        render json: { message: I18n.t('organizations.error.create'), 
                      errors: result[:error_message] }, 
              status: :unprocessable_entity
      end
    end

    # To list users without department
    def users
      result = Organizations::V1::Users.new(params).call
      if result["status"]
        render json: { data: result["data"] }
      else # For now, below code is not running for any scenario but future errors can
           # be handled in the given format
        render json: { error: result["error_message"] }, status: :unprocessable_entity
      end
    end

    def departments
      result = Organizations::V1::Departments.new(params).call
      if result["status"]
        render json: { data: result["data"] }
      else
        render json: { error: result["error_message"] }, status: :unprocessable_entity
      end
    end

    private

    def organization_params
      params.require(:organization).permit(:name, domain: [])
    end
     
  end
end
