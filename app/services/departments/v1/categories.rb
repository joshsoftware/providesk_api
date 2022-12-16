module Departments::V1
  class Categories
    def initialize(params)
      @department_id = params[:id]
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
      categories = Category.select(:id, :name).where(department_id: @department.id)
      { 
        status: true,
        data: {
          total: categories.length,
          categories: categories.order(name: :asc)
        }
      }.as_json
    end
  end
end
