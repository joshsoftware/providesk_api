class RerouteEmailInterceptor
  def self.delivering_email(mail)
    if ['development', 'staging'].include?(Rails.env)
      original_to = mail.header[:to].to_s
      original_subject = mail.header[:subject].to_s

      mail.to = Rails.application.credentials[:interceptor_mail_recepients]
      subject = "#{original_subject} [originally to: #{original_to}]"

      if mail.cc.present?
        original_cc_emails = mail.cc.dup.join(", ")
        mail.cc = []
        subject += "[cc: #{original_cc_emails}]"
      end
      mail.subject = subject
    end
  end
end
