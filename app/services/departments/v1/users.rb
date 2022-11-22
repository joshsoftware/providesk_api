module Departments::V1
  class Users < ApplicationController
    def initialize(params, current_user)
      @current_user = current_user
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
      return 'none' if @department_id == 'none'
      @department = Department.where(id: @department_id).last
      return false if @department.nil?
      @department
    end

    def show_users
      byebug
      if @department_id == 'none'
        users = User.where(department_id: nil, organization_id: @current_user.organization_id)
      elsif(@department.organization_id.eql?(@current_user.organization_id))
        users = User.where(department_id: @department.id)
      end
      if users
        byebug
        { 
          status: true,
          data: {
            total: users.length,
            users: serialize_resource(users.order(created_at: :desc), UserSerializer)
          }
        }.as_json
      else
        { 
          status: false,
          error: "unauthorized_user"
        }.as_json
      end
    end
  end
end