class OrderEventJob < ApplicationJob
  queue_as :default

  def perform(order_id, status)
    puts "Event: Order #{order_id} status changed to #{status}"
  end
end