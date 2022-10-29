class RerouteEmailInterceptor
  def self.delivering_email(mail)
    if ['production', 'development'].include?(Rails.env)
      mail.to = 'nandini.jhanwar@joshsoftware.com'
    end
  end
end
