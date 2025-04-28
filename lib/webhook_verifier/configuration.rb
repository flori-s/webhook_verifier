# frozen_string_literal: true

module WebhookVerifier
  class Configuration
    attr_accessor :secret, :header_signature_key, :header_timestamp_key, :tolerance

    def initialize
      @secret = nil
      @header_signature_key = 'X-Signature'
      @header_timestamp_key = 'X-Timestamp'
      @tolerance = 5.minutes
    end

    # Forceer de gebruiker om de secret in te stellen via een configuratie
    def validate!
      raise 'Secret is required' unless @secret
    end
  end
end