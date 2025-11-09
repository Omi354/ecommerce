class Customer < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :cart_items, dependent: :destroy
  has_many :orders

  validates :name, presence: true
  validates :status, presence: true

  enum :status, {
    normal: 0, # 通常
    withdrawn: 1, # 退会済
    banned: 2 # 停止
  }

  def line_items_checkout
    line_items = self.cart_items.map do |cart_item|
      {
        quantity: cart_item.quantity,
        price_data: {
          currency: "jpy",
          unit_amount: cart_item.product.price,
          tax_behavior: "inclusive",
          product_data: {
            name: cart_item.product.name,
            metadata: {
              product_id: cart_item.product_id
            }
          }
        }
      }
    end
    line_items
  end
end
