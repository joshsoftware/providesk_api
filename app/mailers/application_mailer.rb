class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.credentials[:sendgrid][:account]
  layout 'mailer'
end
