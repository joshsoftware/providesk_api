module Departments::V1
  class Users < ApplicationController
    def initialize(params)
      @department_id = params[:id]
    end

    def call
      return show_users if department_exists?
      { 
        status: false,
        error: "no_department_found" 
      }.as_json
    end

    def department_exists?
      @department = Department.find_by(id: @department_id)
      return false if @department.nil?
      @department
    end

    def show_users
        users = User.where(department_id: @department.id)
        { 
          status: true,
          data: {
            total: users.length,
            users: serialize_resource(users.order(created_at: :desc), UserSerializer)
          }
        }.as_json
    end
  end
end