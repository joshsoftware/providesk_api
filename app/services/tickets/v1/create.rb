module Tickets::V1
  class Create

    def initialize(params, user)
      @current_user = user
      @title = params[:title]
      @description = params[:description]
      @category_id = params[:category_id]
      @department_id = params[:department_id]
      @ticket_type = params[:ticket_type]
    end

    def call
      set_priority && check_resolver_id && save_ticket
    end

    def set_priority
      @priority = Category.find_by(id: @category_id)&.priority
      return true if @priority
      @response = { status: false, error_message: I18n.t('tickets.error.category') }
    end

    def check_resolver_id
      return @response if @response
      @resolver_id = User.find_by(department_id: @department_id)&.id  #We need to find the manager of the department and assign resolver 
      return true if @resolver_id
      @response = { status: false, error_message: I18n.t('tickets.error.resolver') }
    end

    def save_ticket
      return @response if @response

      @requester_id = @current_user.id
      @ticket = Ticket.new(title: @title, description: @description, priority: @priority,
         department_id: @department_id, category_id: @category_id, resolver_id: @resolver_id,
         requester_id: @requester_id, ticket_type: @ticket_type)
      if @ticket.save
        { status: true }
      else
        { status: false, error_message: @ticket.errors.full_messages.join(", ") }
      end
    end
  end
end
