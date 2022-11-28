module Departments::V1
  class Categories
    def initialize(params)   ##need your help
      # @current_user = current_user
      @department_id= params[:id]
    end

    def call
      return show_categories if department_exists?
      { 
        status: false,
        error: "no_department_found" 
      }.as_json
    end

    def department_exists?
      @department = Department.where(id: @department_id).last
      return false if @department.nil?
      @department
    end

    def show_categories
      # if(@department.organization_id.eql?(@current_user.organization_id))
        categories = Category.select(:id, :name).where(department_id: @department.id)
        { 
          status: true,
          data: {
            total: categories.length,
            categories: categories
          }
        }.as_json
      # else``
      #   { 
      #     status: false,
      #     error: "unauthorized_user"
      #   }.as_json
      # end
    end
  end
end
