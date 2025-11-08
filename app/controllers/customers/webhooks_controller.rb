class Customers::WebhooksController < Customers::CustomerBaseController
  skip_before_action :verify_authenticity_token

  def create
    endpoint_secret = Rails.application.credentials.dig(:stripe, :endpoint_secret)

    payload = request.body.read
    event = nil

    begin
      event = Stripe::Event.construct_from(
        JSON.parse(payload, symbolize_names: true)
      )
    rescue JSON::ParserError => e
      # Invalid payload
      status 400
      return
    end

    # Check that you have configured webhook signing
    if endpoint_secret
      # Retrieve the event by verifying the signature using the raw body and the endpoint secret
      signature = request.env['HTTP_STRIPE_SIGNATURE'];
      begin
        event = Stripe::Webhook.construct_event(
          payload, signature, endpoint_secret
        )
      rescue Stripe::SignatureVerificationError => e
        puts "⚠️  Webhook signature verification failed. #{e.message}"
        status 400
      end
    end

    # Handle the event
    case event.type
    when 'checkout.session.completed'
      begin
        session = event.data.object
        response = Stripe::Checkout::Session.retrieve({
          id: session.id,
          expand: ['line_items']
        })

        puts '----------------'
        pp response.line_items.data
        puts '----------------'
        # Order.create!(
        #   customer_id: session.client_reference_id,
        #   name: session.collected_information.shipping_details.name,
        #   postal_code: session.collected_information.shipping_details.address.postal_code,
        #   prefecture: session.collected_information.shipping_details.address.state,
        #   city: session.collected_information.shipping_details.address.city,
        #   address1: session.collected_information.shipping_details.address.line1,
        #   address2: session.collected_information.shipping_details.address.line2,
        #   postage: session.shipping_options[0].shipping_amount,
        #   billing_amount: session.amount_total,
        #   status: session.status
        # )
      rescue StandardError => e
        Rails.logger.error <<~LOG
          [ERROR] #{e.class}: #{e.message}
          #{e.backtrace.join("\n")}
        LOG
      end
    else
      puts "Unhandled event type: #{event.type}"
    end
  end
end


