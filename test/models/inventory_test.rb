require "test_helper"

class InventoryTest < ActiveSupport::TestCase
  test "should not save inventory without item_name" do
    inventory = Inventory.new(quantity: 10, threshold: 2)
    assert_not inventory.save, "Saved the inventory without item_name"
  end

  test "should save valid inventory" do
    inventory = Inventory.new(item_name: "Test Item", quantity: 10, threshold: 2)
    assert inventory.save, "Couldn't save a valid inventory"
  end

  test "should not save inventory with negative quantity" do
    inventory = Inventory.new(item_name: "Test Item", quantity: -5, threshold: 2)
    assert_not inventory.save, "Saved inventory with negative quantity"
  end
end
