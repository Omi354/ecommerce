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
      session = event.data.object
      customer = Customer.find(session.client_reference_id)
      return unless customer

      begin
        ApplicationRecord.transaction do
          order = create_order(session)
          session_with_expand = Stripe::Checkout::Session.retrieve({
            id: session.id,
            expand: ['line_items' ]
          })

          session_with_expand.line_items.data.each do |line_item|
            create_order_detail(order, line_item)
          end

          customer.cart_items.delete_all
        end

        redirect_to session.success_url
      rescue StandardError => e
        puts "ERROR: #{e.message}"
        raise StandardError
      end
    else
      puts "Unhandled event type: #{event.type}"
    end
  end

  private

  def create_order(session)
    Order.create!(
      customer_id: session.client_reference_id,
      name: session.collected_information.shipping_details.name,
      postal_code: session.collected_information.shipping_details.address.postal_code,
      prefecture: session.collected_information.shipping_details.address.state,
      city: session.collected_information.shipping_details.address.city,
      address1: session.collected_information.shipping_details.address.line1,
      address2: session.collected_information.shipping_details.address.line2,
      postage: session.shipping_options[0].shipping_amount,
      billing_amount: session.amount_total,
      status: :confirm_payment
    )
  end

  def create_order_detail(order, line_item)
    product = Stripe::Product.retrieve(line_item.price.product)
    purchased_product = Product.find(product.metadata.product_id)
    return unless purchased_product

    order_detail = order.order_details.create!(
      product_id: purchased_product.id,
      price: line_item.price.unit_amount,
      quantity: line_item.quantity
    )

    purchased_product.update!(stock: purchased_product.stock - order_detail.quantity)
  end
end


