# frozen_string_literal: true

class JwtService
  class << self
    def encode(payload, exp = 24.hours.from_now)
      payload[:exp] = exp.to_i
      JWT.encode(payload, secret_key, 'HS256')
    end

    def decode(token)
      decoded = JWT.decode(token, secret_key, true, { algorithm: 'HS256' })[0]
      HashWithIndifferentAccess.new(decoded)
    rescue JWT::DecodeError, JWT::ExpiredSignature => e
      raise StandardError, "Invalid token: #{e.message}"
    end

    def generate_tokens(user)
      access_payload = {
        user_id: user.id,
        account_id: user.account_id,
        email: user.email,
        role: user.role,
        type: 'access'
      }
      
      refresh_payload = {
        user_id: user.id,
        account_id: user.account_id,
        type: 'refresh'
      }

      {
        access_token: encode(access_payload, 15.minutes.from_now),
        refresh_token: encode(refresh_payload, 7.days.from_now),
        expires_at: 15.minutes.from_now
      }
    end

    def refresh_access_token(refresh_token)
      payload = decode(refresh_token)
      
      raise StandardError, "Invalid token type" unless payload[:type] == 'refresh'
      
      user = User.find(payload[:user_id])
      raise StandardError, "User not found or inactive" unless user&.active?

      generate_tokens(user)
    rescue ActiveRecord::RecordNotFound
      raise StandardError, "User not found"
    end

    private

    def secret_key
      @secret_key ||= Rails.application.config.jwt_secret_key
    end
  end
end