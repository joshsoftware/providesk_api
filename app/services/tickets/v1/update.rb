module Tickets::V1
  class Update
    def initialize(params, ticket_id, user)
      @ticket = Ticket.find ticket_id
      @ticket_result = params
      @user = user
    end

    def call
      if @ticket_result[:is_customer_satisfied] == 'true'
        @ticket.close
        @ticket.save
        return { status: true, success_message: I18n.t('tickets.success.close') }.as_json
      else
        @ticket.reopen
        @ticket[:description] += "[\"Reopen: #{@ticket_result[:started_reason]}\"]"
        @ticket.save
        { status: true, success_message: I18n.t('tickets.success.reopen') }.as_json
      end
    end
  end
end