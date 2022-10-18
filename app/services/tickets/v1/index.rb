module Tickets::V1
 class Index < ApplicationController
  def initialize(filters)
    @department = filters[:department].split(',') if filters[:department]
    @category = filters[:category].split(',') if filters[:category]
    @type = filters[:type].split(',') if filters[:type]
  end

  def call
    where_hash = {}
    if @department
      departments = Department.select(:id).where(name: @department)
      departments_list = []
      departments.each {|department_obj| departments_list.append(department_obj.id) }
      where_hash["department_id"] = departments_list if departments_list != []
    end
    if @category
      categories = Category.select(:id).where(name: @category)
      categories_list = []
      categories.each {|category_obj| categories_list.append(category_obj.id) }
      where_hash["category_id"] = categories_list if categories_list != []
    end
    if @type
      @type.select!{ |x| (x == "complaint" || x == "request") }
      where_hash["ticket_type"] = @type
    end
    if where_hash == {}
      if @department || @type || @category
        return { status: false, 
                message: I18n.t('tickets.show.invalid_filter'), 
                status_code: 422 }.as_json
      end
    end
    tickets = Ticket.where(where_hash)
              .order(created_at: :desc).to_a
    if tickets == []
      { status: false, 
        message: I18n.t('tickets.show.not_available'),
        status_code: 404 }.as_json
    else
      { status: true, tickets: serialize_resource(tickets, TicketSerializer) }.as_json  
    end
  end

 end
end