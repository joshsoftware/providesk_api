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
      @department = Department.new(name: name)
      if @department.save
        { status: true }.as_json
      else
        { status: false, error_message: @department.errors.full_messages.join(", ") }.as_json
      end
    end
  end
end