class Customers::CartItemsController < Customers::CustomerBaseController
  before_action :authenticate_customer!, except: %i[ create ]
  before_action :set_cart_item, only: %i[ destroy increase decrease ]

  def index
    @cart_items = current_customer.cart_items.all
    @sub_total = @cart_items.inject(0) { |result, cart_item| result + cart_item.line_total }
  end

  def create
    product_id = params[:product_id]
    return redirect_to product_path(id: product_id), alert: "ログインしてください" unless customer_signed_in?
    return redirect_to product_path(id: product_id), alert: "カートに追加済です" if CartItem.find_by(customer_id: current_customer.id, product_id: product_id)

    cart_item = current_customer.cart_items.build({
      customer_id: current_customer.id,
      product_id: product_id,
      quantity: 1
    })

    if cart_item.save
      redirect_to product_path(id: cart_item.id), notice: "カートに追加しました"
    else
      redirect_to product_path(id: cart_item.id), alert: "カートの追加に失敗しました"
    end
  end

  def destroy
    @cart_item.destroy!

    redirect_to cart_items_path
  end

  def increase
    if @cart_item.quantity + 1 <= @cart_item.product.stock
      @cart_item.increment!(:quantity, 1)
    else
      flash[:alert] = "在庫数上限です"
    end

    redirect_to cart_items_path
  end

  def decrease
    if @cart_item.quantity == 1
      @cart_item.destroy!
      flash[:notice] = "商品をカートから削除しました"
    else
      @cart_item.decrement!(:quantity, 1)
    end

    redirect_to cart_items_path
  end

  private

  def set_cart_item
    @cart_item = current_customer.cart_items.find(params[:id])
  end
end
