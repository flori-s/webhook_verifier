# frozen_string_literal: true

require 'openssl'
require 'base64'

module WebhookVerifier
  class Verifier
    def self.verify!(request, secret:, tolerance: 5.minutes, header_signature_key: 'X-Signature', header_timestamp_key: 'X-Timestamp')
      signature = request.headers[header_signature_key]
      timestamp = request.headers[header_timestamp_key]

      raise WebhookVerifier::VerificationError, 'Missing signature' unless signature
      raise WebhookVerifier::VerificationError, 'Missing timestamp' unless timestamp

      # Timestamp validation (e.g. must not be older than tolerance)
      raise WebhookVerifier::VerificationError, 'Timestamp is too old' if Time.now - Time.at(timestamp.to_i) > tolerance

      # HMAC signature validation
      expected_signature = generate_hmac(secret, request.body.read, timestamp)
      raise WebhookVerifier::VerificationError, 'Invalid signature' unless valid_signature?(expected_signature, signature)
    end

    private

    def self.generate_hmac(secret, body, timestamp)
      OpenSSL::HMAC.hexdigest('sha256', secret, "#{timestamp}#{body}")
    end

    def self.valid_signature?(expected, actual)
      expected == actual
    end
  end
end