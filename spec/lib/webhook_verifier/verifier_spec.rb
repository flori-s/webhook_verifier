require "openssl"
require "base64"

RSpec.describe WebhookVerifier::Verifier do
  let(:secret_key) { "a6b14ed482348570244e774962fd96c10b44f6bcd0149ee5efa9c720ecbf44e1" }

  before do
    WebhookVerifier.configuration = WebhookVerifier::Configuration.new.tap do |config|
      config.secret = secret_key
      config.header_signature_key = "X-Signature"
      config.header_timestamp_key = "X-Timestamp"
      config.tolerance = 5 * 60  # tolerance in seconds
    end
  end

  let(:timestamp) { Time.now.to_i.to_s }
  let(:valid_body) { '{"name":"John","id":"123"}' }
  let(:invalid_body) { '{"name":"Invalid","id":"999"}' }
  let(:valid_signature) do
    OpenSSL::HMAC.hexdigest("sha256", secret_key, "#{timestamp}#{valid_body}")
  end
  let(:invalid_signature) { "invalidsignature" }

  # Mock request objects
  let(:valid_request) do
    double("request",
           headers: {
             "X-Signature" => valid_signature,
             "X-Timestamp" => timestamp
           },
           body: valid_body)
  end

  let(:invalid_signature_request) do
    double("request",
           headers: {
             "X-Signature" => invalid_signature,
             "X-Timestamp" => timestamp
           },
           body: valid_body)
  end

  let(:missing_signature_request) do
    double("request",
           headers: { "X-Timestamp" => timestamp },
           body: valid_body)
  end

  let(:missing_timestamp_request) do
    double("request",
           headers: { "X-Signature" => valid_signature },
           body: valid_body)
  end

  context "when the signature is valid" do
    it "verifies the webhook signature correctly" do
      expect { WebhookVerifier::Verifier.verify!(valid_request) }.not_to raise_error
    end
  end

  context "when the signature is invalid" do
    it "raises an error if the signature is invalid" do
      expect { WebhookVerifier::Verifier.verify!(invalid_signature_request) }.to raise_error(WebhookVerifier::VerificationError, "Invalid signature")
    end
  end

  context "when the signature is missing" do
    it "raises an error if the signature is missing" do
      expect { WebhookVerifier::Verifier.verify!(missing_signature_request) }.to raise_error(WebhookVerifier::VerificationError, "Missing signature")
    end
  end

  context "when the timestamp is missing" do
    it "raises an error if the timestamp is missing" do
      expect { WebhookVerifier::Verifier.verify!(missing_timestamp_request) }.to raise_error(WebhookVerifier::VerificationError, "Missing timestamp")
    end
  end

  context "when the timestamp is too old" do
    let(:old_timestamp) { (Time.now.to_i - 600).to_s }  # 10 minutes ago

    let(:old_request) do
      double("request",
             headers: {
               "X-Signature" => valid_signature,
               "X-Timestamp" => old_timestamp
             },
             body: valid_body)
    end

    it "raises an error if the timestamp is too old" do
      expect { WebhookVerifier::Verifier.verify!(old_request) }.to raise_error(WebhookVerifier::VerificationError, "Timestamp is too old")
    end
  end

  context "when the secret is not configured" do
    it "raises an error if the secret is not configured" do
      WebhookVerifier.configuration = WebhookVerifier::Configuration.new.tap do |config|
        config.secret = nil
      end
      expect { WebhookVerifier::Verifier.verify!(valid_request) }.to raise_error(WebhookVerifier::VerificationError, "Secret not configured")
    end
  end

  context "when the signature is correct but the body changes" do
    it "raises an error if the signature does not match the modified body" do
      modified_request = double("request",
                                headers: {
                                  "X-Signature" => valid_signature,
                                  "X-Timestamp" => timestamp
                                },
                                body: invalid_body)
      expect { WebhookVerifier::Verifier.verify!(modified_request) }.to raise_error(WebhookVerifier::VerificationError, "Invalid signature")
    end
  end
end