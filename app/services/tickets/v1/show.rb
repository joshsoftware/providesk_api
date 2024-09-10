module Tickets::V1
  class Show < ApplicationController
    def initialize(params, current_user)
      @ticket_id = params[:id]
      @current_user = current_user
    end

    def call
      find_ticket && show_ticket
    end

    def find_ticket
      @ticket = Ticket.find_by(id: @ticket_id)
      if @ticket
        @ticket
      else
        @error = { status: false }.as_json
      end
    end

    def show_ticket
      return @error if @error

      set_value_in_ask_for_update
      { status: true, data: serialize_resource(@ticket, TicketSerializer, role: current_user.role.name), 
                      activities: serialize_resource(@ticket.activities.order(created_at: :desc), ActivitySerializer) }.as_json
    end

    private

    # ask_for_update sets to true if eta < current time. Once asked, if last asked for update is greator than one day,
    # then the value again sets to true.  

    def set_value_in_ask_for_update
      if (@ticket.eta - Time.now.to_date).to_i < 0 && (@ticket.asked_for_update_at.blank? || (Time.now.to_date - @ticket.asked_for_update_at.to_date).to_i > 1)
        Ticket.const_set('ASK_FOR_UPDATE', true ) 
      else
        Ticket.const_set('ASK_FOR_UPDATE', false )
      end
    end
  end
end
