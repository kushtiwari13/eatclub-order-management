class Order < ApplicationRecord
  validates :status, presence: true
  has_many :order_items
end
