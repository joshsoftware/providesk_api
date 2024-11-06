module Tickets::V1
  class Create

    def initialize(params, current_user)
      @current_user = current_user
      @title = params[:title]
      @description = params[:description]
      @category_id = params[:category_id]
      @department_id = params[:department_id]
      @ticket_type = params[:ticket_type]
      @resolver_id = params[:resolver_id]
      @params = params
    end

    def call
      check_department && set_priority && check_resolver_id && save_ticket 
    end

    def check_department
      department = Department.find_by(id: @department_id)
      return true if department
      @response = { status: false, error_message: I18n.t('tickets.error.department') }
    end

    def set_priority # Check existance of Category, and set the priority
      return @response if @response
      @category = Category.find_by(id: @category_id, department_id: @department_id)
      if @category
        @priority = @category&.priority
      else
        @response = { status: false, error_message: I18n.t('tickets.error.category') }
      end
    end

    def check_resolver_id
      return @response if @response

      @resolver = User.find_by(department_id: @department_id, id: @resolver_id) # We need to find the manager of the department and assign resolver 
      return true if @resolver
      @response = { status: false, error_message: I18n.t('tickets.error.resolver') }
    end

    def save_ticket
      return @response if @response
      @requester_id = @current_user.id
      @ticket = Ticket.new(title: @title, description: @description, priority: @priority,
         department_id: @department_id, category_id: @category_id, resolver_id: @resolver_id,
         requester_id: @requester_id, ticket_type: @ticket_type, organization_id: @current_user.organization_id,
         eta: set_eta)
      @ticket[:asset_url] = @params[:asset_url] if @params[:asset_url].present?
      if @ticket.save
        { status: true }
      else
        { status: false, error_message: @ticket.errors.full_messages.join(", ") }
      end
    end

    private

    def set_eta
      sla_duration_in_hours = Category.find(@category_id)&.duration_in_hours
      if sla_duration_in_hours
        Date.today + (sla_duration_in_hours / 24).to_i.days
      else
        Date.today + 7.days 
      end
    end
  end
end
