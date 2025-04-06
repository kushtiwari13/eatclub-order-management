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
    order = Order.find(params[:id])
  
    # Allowed statuses
    valid_statuses = ["preparing", "out_for_delivery", "delivered"]
  
    new_status = status_params[:status]
  
    unless valid_statuses.include?(new_status)
      return render json: { error: "Invalid status. Allowed statuses: #{valid_statuses.join(', ')}" }, status: :unprocessable_entity
    end
  
    order.update!(status: new_status)
  
    render json: { message: "Order status updated successfully", order_id: order.id, new_status: order.status }, status: :ok
  
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Order not found" }, status: :not_found
  rescue => e
    render json: { error: e.message }, status: :unprocessable_entity
  end
  


  def show
    order = Order.find(params[:id])
    render json: order, include: :order_items
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Order not found' }, status: :not_found
  end

  private

  def order_params
    params.require(:order).permit(order_items: [:inventory_id, :quantity])
  end

  def status_params
    params.require(:order).permit(:status)
  end

end
