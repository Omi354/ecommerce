class Customers::CheckoutsController < Customers::CustomerBaseController
  before_action :authenticate_customer!

  def create
    line_items = current_customer.line_items_checkout
    session = create_session(line_items)
    redirect_to session.url, allow_other_host: true
    # redirect_to products_path
    # render turbo_stream: turbo_stream.action(:redirect, session.url)
  end

  def success; end

  def create_session(line_items)
    session = Stripe::Checkout::Session.create({
      customer_email: current_customer.email,
      client_reference_id: current_customer.id,
      line_items:,
      mode: "payment",
      payment_method_types: [ "card" ],
      success_url: root_url,
      cancel_url: "#{root_url}cart_items",
      shipping_address_collection: { allowed_countries: [ "JP" ] },
      shipping_options: [
        {
          shipping_rate_data: {
            display_name: "配送料",
            type: "fixed_amount",
            fixed_amount: {
              amount: 500,
              currency: "jpy"
            }
          }
        }
      ]
    })

    session
  end
end
