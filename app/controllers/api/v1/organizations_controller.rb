module Api::V1
  class OrganizationsController < ApplicationController
    def show_departments
      result = Organizations::V1::ShowDepartments.new(params, current_user).call
      if result["status"]
        render json: { data: result["data"] }
      else
        if result["error"].eql?("No organization found")
          render json: {message: I18n.t('organization.error.invalid_organization_id')}, status: :unprocessable_entity
        elsif result["error"].eql?("Unauthorized user")
          render json:{ message: I18n.t('organization.error.unauthorized_user')}, status: 403
        end
      end
    end
  end
end
