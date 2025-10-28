class Product < ApplicationRecord
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
    message: '全く同じ商品名・商品説明・金額のセットが他にも存在します'
  }
end
