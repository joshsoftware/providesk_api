module Tickets::V1
  class Index

    def initialize(params)
      @filter_hash = {}
      @filter_hash[:department_id] = params[:department_id] if params[:department_id].present?
      @filter_hash[:category_id] = params[:category_id] if params[:category_id].present?
      @ticket_status = params[:status]
      @for_mobile = params[:for_mobile]
    end

    def call
      get_tickets && get_response
    end

    def get_tickets
      @ticket_counts = {}
      @tickets = []
      if @ticket_status.present?
        @tickets = case @ticket_status
        when 'open'
          get_open_tickets()
        when 'closed'
          get_closed_tickets()
        else
          status_tickets = Ticket.of_status(@ticket_status)
          status_tickets
        end
      else
        @tickets = @filter_hash.present? ? Ticket.where(@filter_hash) : Ticket.all
        @tickets
      end
      true
    end

    def get_open_tickets
      inprogress_tickets = Ticket.inprogress
      assigned_tickets = Ticket.assigned
      resolved_tickets = Ticket.resolved
      @ticket_counts[:inprogress_tickets_count] = inprogress_tickets.count
      @ticket_counts[:assigned_tickets_count] = assigned_tickets.count
      @ticket_counts[:resolved_tickets_count] = resolved_tickets.count
      total_tickets = inprogress_tickets + assigned_tickets + resolved_tickets
      total_tickets
    end

    def get_closed_tickets
      closed_tickets = Ticket.closed
      @ticket_counts[:closed_tickets_count] = closed_tickets.count
      total_tickets = closed_tickets
      if @for_mobile.present?
        rejected_tickets = Ticket.rejected
        @ticket_counts[:rejected_tickets_count] = rejected_tickets.count
        total_tickets += rejected_tickets
      end
      total_tickets
    end

    def get_response
      if @tickets.present?
        @ticket_counts[:total_ticket_counts] = @tickets.count
        response_hash = {
          data: { 
            tickets: @tickets.collect{ |x| x.listing_data_attributes } 
          },
          ticket_counts: @ticket_counts
        }.as_json
      else
        response_hash = {
          data: {},
          error_message: I18n.t('tickets.index.not_found')
        }.as_json
      end
    end
  end
end
