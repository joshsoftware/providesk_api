# frozen_string_literal: true

class JsonWebToken
  class << self
    def encode(payload, exp = 1.week.from_now)
      payload[:exp] = exp.to_i
      JWT.encode(payload, secret_key_base)
    rescue StandardError
      nil
    end

    def decode(token)
      body = JWT.decode(token, secret_key_base)[0]
      HashWithIndifferentAccess.new body
    rescue JWT::ExpiredSignature
      false
    rescue StandardError
      nil
    end

    def secret_key_base
      return Rails.application.secret_key_base if Rails.env.eql?('production')
      Rails.application.secrets.secret_key_base
    end
  end
end
