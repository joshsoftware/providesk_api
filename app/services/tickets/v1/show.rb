# frozen_string_literal: true

module Tickets::V1
  class Show
    def initialize(params)
      @ticket_id = params[:id]
    end

    def call
      find_ticket && response
    end

    def find_ticket
      @ticket = Ticket.find_by(id: @ticket_id)
      return true if @ticket

      false
    end

    def response
      @ticket.as_json(
        only: %i[id status title description ticket_number ticket_type priority created_at resolved_at],
        include: [{
          activities: { only: %i[created_at asset_url description id] },
          resolver: { only: %i[id name] }
        }],
        methods: %i[department_name category_name]
      )
    end
  end
end
