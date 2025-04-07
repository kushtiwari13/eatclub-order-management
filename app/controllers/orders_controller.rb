class OrdersController < ApplicationController

  def create
    order = nil
  
    ActiveRecord::Base.transaction do
      order = Order.create!(status: "preparing")
  
      order_params[:order_items].each do |item|
        inventory = Inventory.find(item[:inventory_id])
  
        # Check inventory quantity
        if inventory.quantity < item[:quantity]
          raise StandardError.new("Insufficient inventory for #{inventory.item_name}")
        end
  
        # Deduct inventory
        inventory.update!(quantity: inventory.quantity - item[:quantity])
        
        # Alert if low stock
        if inventory.quantity < inventory.threshold
          InventoryAlertJob.perform_later(inventory.id)
        end

        # Create order item
        OrderItem.create!(
          order: order,
          inventory: inventory,
          quantity: item[:quantity]
        )
      end
    end
  
    render json: { message: "Order placed successfully", order_id: order.id }, status: :created
  
  rescue ActiveRecord::RecordNotFound => e
    render json: { error: "Inventory item not found: #{e.message}" }, status: :not_found
  rescue StandardError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
  
  

  def update
    order = Order.includes(order_items: :inventory).find(params[:id])
  
    valid_statuses = ["preparing", "out_for_delivery", "delivered", "cancelled"]
    new_status = status_params[:status]
  
    unless valid_statuses.include?(new_status)
      return render json: { error: "Invalid status. Allowed statuses: #{valid_statuses.join(', ')}" }, status: :unprocessable_entity
    end
  
    ActiveRecord::Base.transaction do
      # Step 1: If status is being changed to "cancelled"
      if new_status == "cancelled" && order.status != "cancelled"
        order.order_items.each do |item|
          inventory = item.inventory
          inventory.update!(quantity: inventory.quantity + item.quantity)
        end
      end
  
      # Step 2: Update the order status
      order.update!(status: new_status)

      OrderEventJob.perform_later(order.id, order.status)
    end
  
    render json: { message: "Order status updated successfully", order_id: order.id, new_status: order.status }, status: :ok

  rescue ActiveRecord::RecordNotFound
    render json: { error: "Order not found" }, status: :not_found
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
  


  def show
    order = Order.includes(order_items: :inventory).find(params[:id])
  
    order_data = {
      order_id: order.id,
      status: order.status,
      items: order.order_items.map do |item|
        {
          inventory_item_id: item.inventory.id,
          item_name: item.inventory.item_name,
          quantity: item.quantity
        }
      end
    }
  
    render json: order_data, status: :ok
  
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Order not found" }, status: :not_found
  end
  

  private

  def order_params
    params.require(:order).permit(order_items: [:inventory_id, :quantity])
  end

  def status_params
    params.require(:order).permit(:status)
  end

end
