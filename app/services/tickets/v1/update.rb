module Tickets::V1
  class Update
    def initialize(update_request_params, current_user)
      @update_params = update_request_params
      @ticket_id = update_request_params[:id]
      @status = update_request_params[:status]
      @category_id = update_request_params[:category_id]
      @department_id = update_request_params[:department_id]
      @resolver_id = update_request_params[:resolver_id]
      @current_user = current_user
    end

    def call
      find_ticket && find_department && category_check && resolver_check && change_status && update
    end

    def find_ticket
      if @ticket = Ticket.find_by(id: @ticket_id)
        return true
      else 
        @error = { status: false, error_message: I18n.t('tickets.error.not_exists') }.as_json
      end
    end

    def find_department
      return @error if @error
      if @department_id.present?
        @department = Department.find_by(id: @department_id, organization_id: @ticket.organization_id)
      else
        return true
      end

      return true if @department
      @error = { status: false, error_message: I18n.t('tickets.error.department') }.as_json
    end

    def category_check
      return @error if @error

      if @department_id.present? && @category_id.present?
        @department = Department.find_by(id: @department_id)
        @category = Category.find_by(id: @category_id, department_id: @department_id)
      elsif @category_id.present?
        @category = Category.find_by(id: @category_id, department_id: @ticket.department_id)
      else
        return true
      end
 
      return true if @category

      @error = { status: false, error_message: I18n.t('tickets.error.category') }.as_json
    end

    def resolver_check
      return @error if @error

      if @department_id.present? && @resolver_id.present?
        @department = Department.find_by(id: @department_id)
        @resolver = User.find_by(id: @resolver_id, department_id: @department_id)
      elsif @resolver_id.present?
        @resolver = User.find_by(id: @resolver_id, department_id: @ticket.department_id)
      else
        return true
      end

      return true if @resolver
      
      @error = { status: false, error_message: I18n.t('tickets.error.resolver') }.as_json
    end

    def change_status
      return @error if @error

      if @status.present?
        begin
          set_status(@ticket, @status)
        rescue AASM::InvalidTransition
          @error = { status: false, error_message: "Invalid transition from #{@ticket.status} to #{@status}" }.as_json
        end
      else
        return true
      end
    end

    def update
      return @error if @error
      return { status: true }.as_json if @ticket.update(@update_params.except(:id))
    end

    def set_status(ticket, status)
      case status
      when "inprogress"
        ticket.start
      when "for_approval"
        ticket.approve
      when "rejected"
        ticket.reject
      when "resolved"
        ticket.resolve
      when "closed"
        ticket.close
      end
    end
  end
end
