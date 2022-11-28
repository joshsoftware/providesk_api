module Organizations::V1
  class Departments
    def initialize(params)
      @organization_id = params[:id]
    end

    def call
      show_departments
    end

    def show_departments
      departments = Department.select(:id, :name).where(organization_id: @organization.id)
        { 
          status: true,
          data: {
            total: departments.length,
            departments: departments
          }
        }.as_json
    end
  end
end
