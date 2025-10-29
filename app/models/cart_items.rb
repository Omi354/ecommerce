class CartItems < ApplicationRecord
  belongs_to :customer, dependent: :destroy
  belongs_to :product, dependent: :destroy

  validates :quantity, presence: true
end
