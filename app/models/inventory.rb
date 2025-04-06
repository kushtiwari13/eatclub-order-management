class Inventory < ApplicationRecord
  has_many :order_items
end
