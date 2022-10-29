require 'reroute_email_interceptor'

if ['production', 'development'].include?(Rails.env)
  ActionMailer::Base.register_interceptor(RerouteEmailInterceptor)
end
