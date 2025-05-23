# Webhook Verifier Gem

A Ruby gem to securely verify incoming webhooks by validating HMAC signatures, timestamps, and preventing replay attacks.

## Features
- Verify webhook payload signatures with HMAC
- Validate webhook timestamps to prevent replay attacks
- Configurable signature secret and header names
- Easy integration with Rails or any Ruby application
- Support for retry handling and logging

## Installation

Add this line to your application’s Gemfile:

```ruby
gem 'webhook_verifier'
```

And then execute:

```bash
bundle install
```

Or install it yourself:

```bash
gem install webhook_verifier
```

## Ruby version

***This gem is tested with Ruby 3.0.4.***

## Configuration

Configure the verifier with your webhook secret and options:

```ruby
verifier = WebhookVerifier.new(
  secret: ENV['WEBHOOK_SECRET'],
  signature_header: 'X-Webhook-Signature',
  timestamp_header: 'X-Webhook-Timestamp',
  allowed_drift_seconds: 300 # 5 minutes
)
```

## Usage

In your webhook controller:

```ruby
class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token

  def receive
    payload = request.raw_post
    headers = request.headers

    verifier = WebhookVerifier.new(secret: ENV['WEBHOOK_SECRET'])

    unless verifier.valid?(payload, headers)
      head :unauthorized and return
    end

    # Process webhook data...

    head :ok
  end
end
```

## Database creation / Initialization

No database setup needed for this gem.
```
# TODO: Log webhooks in database
```

## Running tests

Run the test suite with:

```bash
bundle exec rspec
```

## Deployment instructions

***Just make sure to set the WEBHOOK_SECRET environment variable on your production servers.***

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/flori-s/webhook_verifier. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/flori-s/webhook_verifier/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the WebhookVerifier project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/flori-s/webhook_verifier/blob/master/CODE_OF_CONDUCT.md).
