module Tickets::V1
  class Index < ApplicationController
    def initialize(filters, current_user)
      @current_user = current_user
      @department_id = filters[:department_id] if filters[:department_id].present?
      @category_id = filters[:category_id] if filters[:category_id].present?
      @type = filters[:type].split(',') if filters[:type]
      @status = filters[:status].split(',') if filters[:status]
      @created_by_me = filters[:created_by_me] if filters[:created_by_me]
      @assigned_to_me = filters[:assigned_to_me] if filters[:assigned_to_me]
      @organization_id = current_user.organization_id
    end
 
    def call
      where_hash = {}
      where_hash["organization_id"] = @organization_id
      error_message = []
      if @department_id.present?
        departments_list = (Department.select(:id).where(id: @department_id, organization_id: @organization_id)).pluck(:id)
        if departments_list.empty?
          error_message.append("Department Invalid")
        else
          where_hash["department_id"] = departments_list if departments_list != []
        end
      end
      if @category_id.present?
        category_list = (Category.select(:id).where(id: @category_id)).pluck(:id)
        if category_list.empty?
          error_message.append("Category Invalid")
        else
          where_hash["category_id"] = category_list if category_list != []
        end
      end
      if @type
        @type.select!{ |x| x if Ticket.ticket_types.include? x}
        where_hash["ticket_type"] = @type
      end
      if @status
        @status.select!{ |x| x if Ticket.statuses.include? x }
        where_hash["status"] = @status
      end
      if error_message != []
        return { status: false, 
                message: I18n.t('tickets.show.invalid_filter') + ", " + error_message.join(", "), 
                status_code: 422 }.as_json
      end
      if @assigned_to_me && @created_by_me && where_hash.length == 1
        tickets = Ticket.where(requester_id: @current_user.id).or(Ticket.where(resolver_id: @current_user.id))  
      elsif @assigned_to_me && where_hash.length == 1
        tickets = Ticket.where(resolver_id: @current_user.id)
      elsif @created_by_me && where_hash.length == 1
        tickets = Ticket.where(requester_id: @current_user.id)
      elsif @current_user.is_employee?
        tickets = Ticket.where(requester_id: @current_user.id)
      # elsif @current_user.is_resolver?
      #   if !@assigned_to_me && !@created_by_me && where_hash.length == 1
      #     tickets = Ticket.where(resolver_id: @current_user.id).or(Ticket.where(requester_id: @current_user.id))
      #   elsif !@assigned_to_me && !@created_by_me && where_hash.length > 1
      #     tickets = Ticket.where(where_hash).and(Ticket.where(resolver_id: @current_user.id))
      #   elsif @assigned_to_me && @created_by_me && where_hash.length > 1
      #     tickets = Ticket.where(where_hash).and((Ticket.where(requester_id: @current_user.id)).or\
      #                                            (Ticket.where(resolver_id: @current_user.id)))
      #   elsif @assigned_to_me && where_hash.length > 1
      #     tickets = Ticket.where(where_hash).and(Ticket.where(resolver_id: @current_user.id))
      #   elsif @created_by_me && where_hash.length > 1
      #     tickets = Ticket.where(where_hash).and(Ticket.where(requester_id: @current_user.id))
      #   end
      elsif @current_user.is_department_head?
        if !@assigned_to_me && !@created_by_me && where_hash.length == 1
          tickets = Ticket.where(where_hash).and(Ticket.where(department_id: @current_user.department_id)).or\
                   (Ticket.where(requester_id: @current_user.id)).or(Ticket.where(resolver_id: @current_user.id))
        elsif !@assigned_to_me && !@created_by_me && where_hash.length > 1
          tickets = Ticket.where(where_hash).and(Ticket.where(department_id: @current_user.department_id))
        elsif @assigned_to_me && @created_by_me && where_hash.length > 1
          tickets = Ticket.where(where_hash).and(Ticket.where(department_id: @current_user.department_id)).and\
                   ((Ticket.where(requester_id: @current_user.id)).or(Ticket.where(resolver_id: @current_user.id)))
        elsif @assigned_to_me && where_hash.length > 1
          tickets = Ticket.where(where_hash).and(Ticket.where(resolver_id: @current_user.id))
        elsif @created_by_me && where_hash.length > 1
          tickets = Ticket.where(where_hash).and(Ticket.where(requester_id: @current_user.id))
        end
      elsif @current_user.is_admin?
        if !@assigned_to_me && !@created_by_me && where_hash.length == 1
          tickets = Ticket.where(where_hash).or(Ticket.where(requester_id: @current_user.id)).or\
                   (Ticket.where(resolver_id: @current_user))
        elsif !@assigned_to_me && !@created_by_me && where_hash.length > 1
          tickets = Ticket.where(where_hash)
        elsif @assigned_to_me && @created_by_me && where_hash.length > 1
          tickets = Ticket.where(where_hash).and((Ticket.where(requester_id: @current_user.id)).or\
                   (Ticket.where(resolver_id: @current_user)))
        elsif @assigned_to_me && where_hash.length > 1
          tickets = Ticket.where(where_hash).and(Ticket.where(resolver_id: @current_user.id))
        elsif @created_by_me && where_hash.length > 1
          tickets = Ticket.where(where_hash).and(Ticket.where(requester_id: @current_user.id))
        end
      end
      if tickets == []
        { status: false,
          data: [] ,
          message: I18n.t('tickets.show.not_availaible'),
          status_code: 200 }.as_json
      else
        { status: true, tickets: serialize_resource(tickets.order(created_at: :desc).to_a, TicketSerializer) }.as_json  
      end
    end
 
    def change_case(list)
      list.each do |ele|
        if ele.length <= 3
          ele.upcase!
        else
          ele.capitalize!
        end
      end
      list
    end
  end
 end