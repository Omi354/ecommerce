class Customer < ApplicationRecord
  with_options presence: true
    validates :name,
    validates :description,
    validates :price,
    validates :stock
  end
  validates :name, uniqueness: {
    scope: {
      :description,
      :price
    },
    message: '全く同じ商品名・商品説明・金額のセットが他にも存在します'
  }
end
