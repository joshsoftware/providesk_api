module Tickets::V1
  class Timeline < ApplicationController
    def initialize(current_user)
      @user = current_user
    end

    def call
      tickets_overdue = {}
      if @user.is_admin?
        tickets_overdue["overdue"] = Ticket.where("eta < ?", Time.now).order(id: :asc)
        tickets_overdue["overdue_in_two_days"] = Ticket.where(eta: Time.now..2.days.from_now).order(id: :asc)
        tickets_overdue["overdue_after_two_days"] = Ticket.where("eta > ?", Time.now + 2.day).order(eta: :asc)
      elsif @user.is_department_head? || @user.is_resolver?
        tickets_overdue["overdue"] = Ticket.where("eta < ? AND department_id = ?", Time.now, @user.department_id)
                                           .order(id: :asc)
        tickets_overdue["overdue_in_two_days"] = Ticket.where("eta BETWEEN ? AND ? AND department_id = ?", Time.now, 2.days.from_now, @user.department_id)
                                                       .order(id: :asc)
        tickets_overdue["overdue_after_two_days"] = Ticket.where("eta > ? AND department_id = ?", Time.now + 2.day, @user.department_id)
                                                          .order(eta: :asc)
      end
      
      serialize_tickets(tickets_overdue)
      { status: true, data: tickets_overdue }.as_json
    end

    private

    def serialize_tickets(tickets_overdue)
      tickets_overdue.each do |key, val|
        tickets_overdue[key] = serialize_resource(tickets_overdue[key], TicketSerializer)
      end
    end
  end
end