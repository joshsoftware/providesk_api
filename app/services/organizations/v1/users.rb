module Organizations::V1
  class Users < ApplicationController
    def initialize(params)
      @organization_id = params[:id]
    end

    def call
      show_users
    end

    def show_users
      users = User.where(organization_id: @organization_id, department_id: nil)
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