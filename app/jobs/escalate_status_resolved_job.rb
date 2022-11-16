class EscalateStatusResolvedJob < ApplicationJob
  queue_as :default
  def perform
    Ticket.where(status: "resolved").each do |ticket|
      activities = ticket.activities.order(created_at: :desc)
      activities.each do |activity|
        if activity.assigned_from != activity.assigned_to
          ((Time.current - activity.created_at)/3600).to_i > Ticket::ESCALATE_STATUS[:resolved].days.in_hours.to_i
          ticket.send_email_to_department_head
          break
        elsif activity.current_ticket_status != activity.previous_ticket_status
          ((Time.current - activity.created_at)/3600).to_i > Tikcet::ESCALATE_STATUS[:resolved].days.in_hours.to_i
          ticket.send_email_to_department_head
          break
        end
      end
    end
  end
end
