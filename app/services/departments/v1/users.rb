module Departments::V1
  class Users < ApplicationController
    def initialize(params,current_user)
      @department_id = params[:id]
      @category_id = params[:category_id] if params[:category_id]
      @current_user = current_user
    end

    def call
      if department_exists?[:error_message]
        { status: false, errors: department_exists?[:error_message] }.as_json
      else
        if defined? @category_id
          category_exists?[:error_message] ? { status: false, errors: category_exists?[:error_message] }.as_json 
                                           : show_users_with_category
        else
          show_users_with_department
        end
      end
    end

    def department_exists?
      @department = Department.find_by(id: @department_id)
      !@department.nil? ? @department : { error_message: I18n.t('department.error.invalid_department_id') }
    end

    def category_exists?
      @category = Category.find_by(id: @category_id)
      !@category.nil? ? @category : { error_message: I18n.t('tickets.error.category') }
    end

    def show_users_with_department
      users = User.where(department_id: @department.id, organization_id:@ current_user.organization_id)
      { 
        status: true,
        data: {
          total: users.length,
          users: serialize_resource(users.order(name: :asc), UserSerializer)
        }
      }.as_json
    end

    def show_users_with_category
      users = User.joins(:categories).where(categories: {id: @category_id}).where(department_id: @department_id)
      { 
        status: true,
        data: {
          total: users.length,
          users: serialize_resource(users.order(name: :asc), UserSerializer)
        }
      }.as_json
    end
  end
end
