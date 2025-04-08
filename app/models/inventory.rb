class Inventory < ApplicationRecord
  validates :item_name, presence: true
  validates :quantity, numericality: { greater_than_or_equal_to: 0 }
  validates :threshold, numericality: { greater_than_or_equal_to: 0 }
  has_many :order_items
end
