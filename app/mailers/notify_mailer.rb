class NotifyMailer < ApplicationMailer

  def notify_status_change(receiver, sencodary_receiver, description, ticket_id)
    @description = description
    mail(to: receiver.email, cc: sencodary_receiver.email, subject: "Ticket-#{ticket_id} progress notifcation")
  end
end
