require "test_helper"

class OrdersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @inventory = Inventory.create!(item_name: "Test Item", quantity: 10, threshold: 2)
  end

  test "should create order" do
    post orders_url, params: {
      order: {
        order_items: [
          { inventory_id: @inventory.id, quantity: 1 }
        ]
      }
    }, as: :json

    assert_response :created
  end

  test "should not create order with insufficient inventory" do
    post orders_url, params: {
      order: {
        order_items: [
          { inventory_id: @inventory.id, quantity: 100 }
        ]
      }
    }, as: :json

    assert_response :unprocessable_entity
  end

  test "should not create order with invalid inventory id" do
    post orders_url, params: {
      order: {
        order_items: [
          { inventory_id: 9999, quantity: 1 }
        ]
      }
    }, as: :json
  
    assert_response :not_found
  end
  test "should not update order with invalid status" do
    order = Order.create!(status: "preparing")
    patch order_url(order), params: {
      order: { status: "invalid_status" }
    }, as: :json
  
    assert_response :unprocessable_entity
  end

  test "should cancel order and increase inventory" do
    inventory = Inventory.create!(item_name: "Test Item", quantity: 10, threshold: 2)
    order = Order.create!(status: "preparing")
    OrderItem.create!(order: order, inventory: inventory, quantity: 2)
  
    patch order_url(order), params: {
      order: { status: "cancelled" }
    }, as: :json
  
    assert_response :ok
    inventory.reload
    assert_equal 12, inventory.quantity, "Inventory quantity did not increase on cancel"
  end

end
