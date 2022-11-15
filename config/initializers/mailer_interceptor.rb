require 'reroute_email_interceptor'

if ['development'].include?(Rails.env)
  ActionMailer::Base.register_interceptor(RerouteEmailInterceptor)
end
