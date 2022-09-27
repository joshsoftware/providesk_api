module Departments::V1
  class ShowUsers
    def initialize(params, current_user)
      @current_user = current_user
      @department_id= params[:department_id]
    end

    def call
      return show_users if department_exists?
      { 
        status: false,
        error: "No department found" 
      }.as_json
    end

    def department_exists?
      @department = Department.where(id: @department_id).last
      return false if @department.nil?
      @department
    end

    def show_users
      if(@department.organization_id.eql?(@current_user.organization_id))
        users = User.select(:id, :name).where(department_id: @department.id)
        { 
          status: true,
          data: {
            total: users.length,
            users: users
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