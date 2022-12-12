class NotifyMailer < ApplicationMailer

  def notify_status_change(receiver, secondary_receiver, description, ticket_id)
    @description = description
    mail(to: receiver.email, cc: secondary_receiver.email, subject: "Ticket-#{ticket_id} progress notifcation")
  end

  def notify_status_escalate(receiver, secondary_receiver, description, ticket_id)
    @description = description
    mail(to: receiver.email, cc: secondary_receiver.email, subject: "Ticket-#{ticket_id} escalation notification")
  end

  def notify_status_update(resolver, requester, ticket_id, ticket_link)
    @resolver, @ticket_link, @requester = resolver.name, ticket_link, requester.name
    mail(to: resolver.email, cc: requester.email, subject: "Requester has asked for update on Ticket-#{ticket_id}")
  end
end
