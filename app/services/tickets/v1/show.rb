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
      { status: true, data: serialize_resource(@ticket, TicketSerializer), 
                      activities: serialize_resource(@ticket.activities.order(created_at: :desc), ActivitySerializer) }.as_json
    end

    private

    # ask_for_update sets to true if eta < current time. Once asked, if last asked for update is greator than one day,
    # then the value again sets to true.
    # If eta is blank and asked_for_update is also blank, then value sets to true if updated_at time of ticket is
    # greator than 2 days
    # If eta is blank and asked for update is not blank, then value sets to true if the difference of updated_at time 
    # last asked_for_update > 1 day 

    def set_value_in_ask_for_update
      if @ticket.eta.blank? 
        if @ticket.asked_for_update_at.blank?
          (Time.now.to_date - @ticket.updated_at.to_date).to_i > 2 ? Ticket.const_set('ASK_FOR_UPDATE', true ) : Ticket.const_set('ASK_FOR_UPDATE', false )
        else
          (@ticket.asked_for_update_at.to_date - @ticket.updated_at.to_date).to_i > 1 ? Ticket.const_set('ASK_FOR_UPDATE', true ) : Ticket.const_set('ASK_FOR_UPDATE', false )
        end
      elsif (@ticket.eta - Time.now.to_date).to_i < 0 && (@ticket.asked_for_update_at.blank? || (Time.now.to_date - @ticket.asked_for_update_at.to_date).to_i > 1)
        Ticket.const_set('ASK_FOR_UPDATE', true ) 
      else
        Ticket.const_set('ASK_FOR_UPDATE', false )
      end
    end
  end
end
