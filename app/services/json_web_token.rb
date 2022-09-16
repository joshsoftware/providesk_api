# frozen_string_literal: true

class JsonWebToken
  class << self
    def encode(payload, exp = 24.hours.from_now)
      payload[:exp] = exp.to_i
      JWT.encode(payload, Rails.application.secrets.secret_key_base)
    rescue StandardError
      nil
    end

    def decode(token)
      body = JWT.decode(token, Rails.application.secrets.secret_key_base)[0]
      HashWithIndifferentAccess.new body
    rescue StandardError
      nil
    end

    def valid_payload(payload)
      if expired(payload)
        false
      else
        true
      end
    end

    def expired(payload)
      Time.zone.at(payload[:exp]) < Time.zone.now
    end
  end
end
