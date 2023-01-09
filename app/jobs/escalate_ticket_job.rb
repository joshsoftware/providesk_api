class EscalateTicketJob < ApplicationJob
  queue_as :default

  def perform
    # Escalation Mail to department head
    escalation_tickets = {}
    tickets = Ticket.where("eta < ?",Date.today).where.not(status: 'closed')

    tickets_by_department = tickets.select(:department_id, :ticket_number, :id)
                             .group_by(&:department_id)
    tickets_by_department.each do |department_id, department_tickets|
      department_name = Department.find(department_id).name
      escalation_tickets[department_name] = []
      department_tickets.each do |ticket|
        escalation_tickets[department_name] << ["#{ticket.ticket_number} => https://providesk.netlify.app/complaints/#{ticket.id}"]
      end
      Ticket.send_escalation_email_to_department_head(escalation_tickets, department_id)
    end

    # Escalation Mail to resolver
    escalation_tickets = {}
    tickets_by_resolver = tickets.select(:ticket_number, :id, :resolver_id)
                             .group_by(&:resolver_id)
    tickets_by_resolver.each do |resolver_id, resolver_tickets|
      resolver_name = User.find(resolver_id).name
      escalation_tickets[resolver_name] = []
      resolver_tickets.each do |ticket|
        escalation_tickets[resolver_name] << ["#{ticket.ticket_number} => https://providesk.netlify.app/complaints/#{ticket.id}"]
      end
      Ticket.send_escalation_email_to_resolver(escalation_tickets[resolver_name], resolver_id)
    end
  end
end