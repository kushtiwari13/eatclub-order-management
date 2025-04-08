require "test_helper"

class OrderTest < ActiveSupport::TestCase
  test "should save order with status" do
    order = Order.new(status: "preparing")
    assert order.save, "Couldn't save order with status"
  end

  test "should not save order without status" do
    order = Order.new
    assert_not order.save, "Saved the order without status"
  end

  test "should not save order item without order and inventory" do
    order_item = OrderItem.new(quantity: 1)
    assert_not order_item.save, "Saved order item without order or inventory"
  end
  
end
