module Tickets::V1
  class Create
    attr_accessor :title, :description, :ticket, :category_id, :department_id,
                  :current_user, :priority, :resolver_id, :requester_id, :ticket_type

    def initialize(params, user)
      @current_user = user
      @title = params[:title]
      @description = params[:description]
      @category_id = params[:category_id]
      @department_id = params[:department_id]
      @ticket_type = params[:ticket_type]
    end

    def call
      set_priority_and_requester_id_and_resolver_id && save_ticket
    end

    def set_priority_and_requester_id_and_resolver_id
      @resolver_id = User.find_by(department_id: department_id)
      @priority = Category.find_by(id: category_id).priority
      @requester_id = current_user.id
    end

    def save_ticket
      @ticket = Ticket.new(title: title, description: description, priority: priority,
         department_id: department_id, category_id: category_id, resolver_id: resolver_id,
         requester_id: requester_id, ticket_type: ticket_type)
      if ticket.save
        { status: true }.as_json
      else
        { status: false, error_message: @ticket.errors.full_messages.join(", ") }.as_json
      end
    end
  end
end
