class InventoryAlertJob < ApplicationJob
  queue_as :default

  def perform(inventory_id)
    inventory = Inventory.find(inventory_id)
    puts "Inventory Alert: '#{inventory.item_name}' is low! Quantity: #{inventory.quantity}, Threshold: #{inventory.threshold}"
  end
end