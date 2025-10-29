class Product < ApplicationRecord
  has_many :cart_items
  has_one_attached :image

  with_options presence: true do
    validates :name
    validates :description
    validates :price
    validates :stock
    validates :image
  end
  validates :name, uniqueness: {
    scope: [
      :description,
      :price
    ],
    message: "全く同じ商品名・商品説明・金額のセットが他にも存在します"
  }

  scope :price_high_to_low, -> { order(price: :desc) }
  scope :price_low_to_high, -> { order(price: :asc) }
end
