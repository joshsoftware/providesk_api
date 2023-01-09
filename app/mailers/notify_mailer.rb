class NotifyMailer < ApplicationMailer
  def notify_status_change(receiver, secondary_receiver, description, ticket_number, ticket_link)
    @description, @ticket_link = description, ticket_link
    mail(to: receiver.email, cc: secondary_receiver.email, subject: "Ticket-#{ticket_number} progress notification")
  end

  def notify_status_escalate(receiver, description, tickets)
    @description, @receiver, @tickets = description, receiver.name, tickets
    mail(to: receiver.email, subject: "Ticket escalation notification")
  end

  def notify_status_update(resolver, requester, ticket_id, ticket_link)
    @resolver, @ticket_link, @requester = resolver.name, ticket_link, requester.name
    mail(to: resolver.email, cc: requester.email, subject: "#{requester} has asked for update on Ticket-#{ticket_number}")
  end
end
