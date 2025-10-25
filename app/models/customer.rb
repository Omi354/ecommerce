class Customer < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, presence: true
  validates :status, presence: true

  enum :status, {
    normal: 0, # 通常
    withdrawn: 1, # 退会済
    banned: 2 # 停止
  }
end
