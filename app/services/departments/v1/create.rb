module Departments::V1
  class Create
    attr_accessor :name, :department

    def initialize(params)
      @current_user = params[:current_user]
      @name = params[:name]
    end

    def call
      save_department
    end

    def save_department
      @department = Department.create!(name: name)
      return department.id.to_s if department

      false
    end
  end
end