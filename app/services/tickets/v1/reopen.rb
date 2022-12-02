module Tickets::V1
  class Reopen
    def initialize(params, ticket_id, user)
      @ticket = Ticket.find ticket_id
      @ticket_result = params
      @user = user
    end

    def call
      begin
        if @ticket_result[:is_customer_satisfied] == 'true'
          @ticket.close
          @ticket.save
          return { status: true, success_message: I18n.t('tickets.success.close') }.as_json
        else
          @ticket.reopen
          @ticket[:reason_for_update] = "Reopen: #{@ticket_result[:started_reason]}"
          @ticket[:asset_url] += @ticket_result[:asset_url]
          @ticket.save
          { status: true, success_message: I18n.t('tickets.success.reopen') }.as_json
        end
      rescue AASM::InvalidTransition
        { status: false, error_message: "Invalid transition from #{@ticket.status} to reopen" }.as_json
      end
    end
  end
end
