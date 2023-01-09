module Tickets::V1
  class BulkUpdateTicketProgress

    def initialize(params)
      @ticket_ids = params[:ticket_ids]
      @department_id = params[:department_id]
      @category_id = params[:category_id]
      @resolver_id = params[:resolver_id]
      @status = params[:status]
      @update_params = params
    end

    def call
      resolver_associated_with_category? && update_tickets
    end

    def resolver_associated_with_category?
      if @resolver_id.present?
        @resolver = UserCategory.exists?(user_id: @resolver_id, category_id: @category_id)
      else 
        return true
      end
      return true if @resolver
      @error = { status: false, error_message: I18n.t('tickets.error.resolver_not_associated_with_category') }.as_json
    end

    def update_tickets
      return @error if @error

      { status: true }.as_json if Ticket.where(id: @ticket_ids).update_all(@update_params.except(:ticket_ids).to_h)
    end
  end
end
