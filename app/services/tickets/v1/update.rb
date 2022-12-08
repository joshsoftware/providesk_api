module Tickets::V1
  class Update
    def initialize(params, ticket_id)
      @ticket_id = ticket_id
      @title = params[:title]
      @description = params[:description]
      @category_id = params[:category_id]
      @department_id = params[:department_id]
      @ticket_type = params[:ticket_type]
      @resolver_id = params[:resolver_id]
      @asset_url = params[:asset_url]
      @edit_params = params
    end

    def call
      find_ticket && check_status && find_department && find_category && find_resolver && ticket_type_check && update
    end

    def find_ticket
      if @ticket = Ticket.find_by(id: @ticket_id)
        return true
      else 
        @error = { status: false, error_message: I18n.t('tickets.error.not_exists') }.as_json
      end
    end

    def check_status
      @ticket.status.eql?('assigned') ? true : (@error = { status: false, error_message: I18n.t('tickets.error.status') }.as_json)
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

    def find_category
      return @error if @error

      if @department_id.present? && @category_id.present?
        @category = Category.find_by(id: @category_id, department_id: @department.id)
      elsif @category_id.present?
        @category = Category.find_by(id: @category_id, department_id: @ticket.department_id)
      else
        return true
      end
 
      return true if @category

      @error = { status: false, error_message: I18n.t('tickets.error.category') }.as_json
    end

    def find_resolver
      return @error if @error

      if @department_id.present? && @resolver_id.present?
        @resolver = User.find_by(id: @resolver_id, department_id: @department.id)
      elsif @resolver_id.present?
        @resolver = User.find_by(id: @resolver_id, department_id: @ticket.department_id)
      else
        return true
      end
      return true if @resolver
      
      @error = { status: false, error_message: I18n.t('tickets.error.resolver') }.as_json
    end

    def ticket_type_check
      @edit_params["ticket_number"] = @ticket_type + "-" + @ticket_id.to_s if @ticket_type.present?
      true
    end

    def update
      return @error if @error

      @edit_params[:asset_url] = @asset_url.blank? ? [] : @asset_url
      return { status: true }.as_json if @ticket.update(@edit_params.except(:id))
    end
  end
end