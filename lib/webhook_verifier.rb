# lib/webhook_verifier.rb
require 'webhook_verifier/verifier'
require 'webhook_verifier/errors'
require 'webhook_verifier/configuration'


module WebhookVerifier
  class << self
    attr_accessor :configuration
  end
end