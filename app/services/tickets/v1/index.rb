module Tickets::V1
 class Index < ApplicationController
  def initialize(filters, current_user)
    @current_user = current_user
    @department = filters[:department].split(',') if filters[:department]
    @category = filters[:category].split(',') if filters[:category]
    @type = filters[:type].split(',') if filters[:type]
    @status = filters[:status].split(',') if filters[:status]
    @created_by_me = filters[:created_by_me] if filters[:created_by_me]
    @assigned_to_me = filters[:assigned_to_me] if filters[:assigned_to_me]
    @organization_id = current_user.organization_id
  end

  def call
    where_hash = {}
    error_message = []
    if @department
      @department = change_case(@department)
      departments_list = (Department.select(:id).where(name: @department, organization_id: @organization_id)).pluck(:id)
      if departments_list.count != @department.count
        error_message.append("Department Invalid")
      else
        where_hash["department_id"] = departments_list if departments_list != []
      end
    end
    if @category
      @category = change_case(@category)
      category_list = (Category.select(:id).where(name: @category)).pluck(:id)
      if category_list.count != @category.count
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
    if @created_by_me && where_hash == {}
      tickets = Ticket.where(requester_id: @current_user.id)
    elsif @assigned_to_me && where_hash == {}
      tickets = Ticket.where(resolver_id: @current_user.id)
    elsif @current_user.is_employee?
      tickets = (Ticket.where(requester_id: @current_user.id)).or(Ticket.where(resolver_id: @current_user)).order(created_at: :desc).to_a
    elsif where_hash == {} && @current_user.is_department_head?
      tickets = Ticket.where(department_id: @current_user.department_id).or(Ticket.where(requester_id: @current_user.id)).or(Ticket.where(resolver_id: @current_user))
              .order(created_at: :desc).to_a
    elsif !@created_by_me && !@assigned_to_me
      tickets = Ticket.where(where_hash)
    else
      tickets = Ticket.where(where_hash).or(Ticket.where(requester_id: @current_user.id)).or(Ticket.where(resolver_id: @current_user))
              .order(created_at: :desc).to_a
    end
    if tickets == []
      { status: false, 
        message: I18n.t('tickets.show.not_availaible'),
        status_code: 200 }.as_json
    else
      { status: true, tickets: serialize_resource(tickets, TicketSerializer) }.as_json  
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