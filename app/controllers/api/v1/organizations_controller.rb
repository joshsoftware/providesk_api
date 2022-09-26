class Api::V1::OrganizationsController < ApplicationController
  def show_departments
    if(current_user.organization_id.eql?(params[:id].to_i))
      organization = Organization.find(params[:id])
      departments = Department.where(organization_id: organization.id)
      departments_list = []
      departments.each do |department|
        departments_list.push(
          {
            name: department.name,
            id: department.id
          }
        )
      end
      render json:{
        data: {
          total: departments_list.length,
          departments: departments_list
        }
      }, status: 200
    else
      render json:{
        message: I18n.t('organization.error.unauthorized_user')
      }, status: 403
    end
  end
end
