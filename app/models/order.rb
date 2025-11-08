class Order < ApplicationRecord
  belongs_to :customer

  has_many :order_details, dependent: :destroy

  enum :status, {
    waiting_payment: 0,
    confirm_payment: 1,
    shipped: 2,
    out_of_delivery: 3,
    delivered: 4
  }
end
