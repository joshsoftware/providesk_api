module Api::V1
  class OrganizationsController < ApplicationController
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
  end
end
