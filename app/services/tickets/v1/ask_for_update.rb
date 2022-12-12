module Tickets::V1
  class AskForUpdate < ApplicationController
    def initialize(params)
      @ticket_id = params[:id]
      @ticket_link = params[:ticket_link]
    end

    def call
      @ticket = Ticket.find @ticket_id
      @ticket.asked_for_update_at = Time.now
      @ticket.save!
      @ticket.send_email_to_resolver(@ticket_link)
      return { status: true }.as_json
    end
  end
end
