class EscalateStatusInprogressJob < ApplicationJob
  queue_as :default

  def perform
    Ticket.where(status: "inprogress").each do |ticket|
      activities = ticket.activities.order(created_at: :desc)
      activities.each do |activity|
        if activity.assigned_from != activity.assigned_to
          ticket.send_email_to_department_head if ((Time.current - activity.created_at)/3600).to_i > Ticket::ESCALATE_STATUS[:inprogress].day.in_hours.to_i
          break
        elsif activity.current_ticket_status != activity.previous_ticket_status
          ticket.send_email_to_department_head if ((Time.current - activity.created_at)/3600).to_i > Ticket::ESCALATE_STATUS[:inprogress].day.in_hours.to_i
          break
        end
      end
    end
  end
end
