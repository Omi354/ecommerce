class Admins::ProductsController < Admins::AdminBaseController
  before_action :set_product, only: %i[ show edit update ]

  def index
    @products = Product.all
  end

  def show; end

  def new
    @product = Product.new
  end

  def create
    @product = Product.new(product_params)
    if @product.save
      redirect_to admin_product_path(@product), notice: '商品を追加しました'
    else
      flash.now[:alert] = '商品の追加に失敗しました'
      render :new
    end
  end

  def edit; end

  def update
    if @product.update(product_params)
      redirect_to admin_product_path(@product), notice: '商品を編集しました'
    else
      flash.now[:alert] = '商品の編集に失敗しました'
      render :edit
    end
  end

  private

  def set_product
    @product = Product.find(params[id])
  end

  def product_params
    params.require(:product).permit(:name, :description, :price, :stock)
  end
end
