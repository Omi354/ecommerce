class CartItem < ApplicationRecord
  belongs_to :customer
  belongs_to :product

  validates :quantity, presence: true

  def line_total
    self.product.price * self.quantity
  end
end
