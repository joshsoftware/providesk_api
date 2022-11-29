module Departments::V1
  class Create
    def initialize(params)
      @name = params[:name]
      @organization_id = params[:organization_id]
    end

    def call
      @department = Department.new(name: @name, organization_id: @organization_id)
      if @department.save
        { status: true }.as_json
      else
        { status: false, error_message: @department.errors.full_messages.join(", ") }.as_json
      end
    end
  end
end