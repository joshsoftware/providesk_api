module Tickets::V1
  class Show < ApplicationController
    def initialize(params, current_user)
      @ticket_id = params[:id]
      @current_user = current_user
    end

    def call
      find_ticket && check_role && show_ticket
    end

    def find_ticket
      @ticket = Ticket.find_by(id: @ticket_id)
      if @ticket
        @ticket
      else
        @error = { status: false }.as_json
      end
    end

    def check_role
      return @error if @error
      if @current_user.is_admin?
        @ticket
      elsif @current_user.is_employee?
        if @ticket.resolver_id == @current_user.id || @ticket.requester_id == @current_user.id
          @ticket
        else
          @error = { status: false }.as_json
        end
      end
    end

    def show_ticket
      return @error if @error
      { status: true, data: serialize_resource(@ticket, TicketSerializer), 
                      activities: serialize_resource(@ticket.activities.order(created_at: :desc), ActivitySerializer) }.as_json
    end
  end
end
