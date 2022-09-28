module Organizations::V1
  class Departments
    def initialize(params, current_user)
      @current_user = current_user
      @organization_id= params[:id]
    end

    def call
      return show_departments if organization_exists?
      { 
        status: false,
        error: "No organization found" 
      }.as_json
    end

    def organization_exists?
      @organization = Organization.where(id: @organization_id).last
      return false if @organization.nil?
      @organization
    end

    def show_departments
      if(@organization.id.eql?(@current_user.organization_id))
        departments = Department.select(:id, :name).where(organization_id: @organization.id)
        { 
          status: true,
          data: {
            total: departments.length,
            departments: departments
          }
        }.as_json
      else
        { 
          status: false,
          error: "Unauthorized user"
        }.as_json
      end
    end
  end
end
