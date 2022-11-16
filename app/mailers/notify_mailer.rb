class NotifyMailer < ApplicationMailer

  def notify_status_change(receiver, secondary_receiver, description, ticket_id)
    @description = description
    mail(to: receiver.email, cc: secondary_receiver.email, subject: "Ticket-#{ticket_id} progress notifcation")
  end

  def notify_status_escalate(receiver, secondary_receiver, description, ticket_id)
    @description = description
    mail(to: receiver.email, cc: secondary_receiver.email, subject: "Ticket-#{ticket_id} escalation notification")
  end
end
