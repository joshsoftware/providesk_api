class EscalateStatusAssignedJob < ApplicationJob
  queue_as :default
  def perform
    tickets = Ticket.where('created_at = updated_at and status = ?', Ticket.statuses["assigned"]).order(:created_at)
    tickets.each do |ticket|
      ticket.send_email_to_department_head
    end
  end
end
