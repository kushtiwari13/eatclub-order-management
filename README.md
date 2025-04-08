

## project overview

this is a scalable backend system for managing real-time orders and inventory in a food delivery platform.

features:
- place orders
- update order status
- manage inventory
- send alerts on low inventory
- emit order status change events (background processing with sidekiq)

---

## system requirements

make sure you have the following installed:

ruby 3.3.7

rails 8.0.2

postgresql 17.4

redis 7.4.2

sidekiq

---

## project setup

### step 1: clone the repository

if you have from github:
```bash
git clone <my-repo-link>
cd eatclub-order-management
```
---

### step 2: install dependencies

```bash
bundle install
```

---

### step 3: setup database

create, migrate, and seed the database:

```bash
rails db:create db:migrate db:seed
```
---

### step 4: start redis server (in a separate terminal)

```bash
redis-server
```
---

### step 5: start sidekiq (another terminal)

```bash
bin/sidekiq
```
---

### step 6: start rails server

```bash
rails s
```

rails will start at:
```
http://localhost:3000
```

---

## testing apis (postman or curl)

### inventory preloaded

Yes, Kush. Here’s your natural, bullet-point style for that section too:

---

you can check seeded inventory in database or run:
```bash
bin/rails console
Inventory.all
```

sample inventory:

- id: 1, item_name: Pizza, quantity: 30, threshold: 3
- id: 2, item_name: Pasta, quantity: 20, threshold: 2
- id: 3, item_name: Burger, quantity: 50, threshold: 5

---

### 1. place an order

**endpoint:**
```
POST http://localhost:3000/orders
```

**body:**
```json
{
  "order": {
    "order_items": [
      { "inventory_id": 1, "quantity": 2 },
      { "inventory_id": 2, "quantity": 1 }
    ]
  }
}
```

**response:**
```json
{
  "message": "Order placed successfully",
  "order_id": 10
}
```

---

### 2. update order status

**endpoint:**
```
PATCH http://localhost:3000/orders/:id
```

replace `:id` with actual order id

**body:**
```json
{
  "order": {
    "status": "out_for_delivery"
  }
}
```

available statuses:
- preparing
- out_for_delivery
- delivered
- cancelled

**response:**
```json
{
  "message": "Order status updated successfully"
}
```

if status is invalid:
```json
{
  "error": "Invalid status"
}
```

---

### 3. fetch order details

**endpoint:**
```
GET http://localhost:3000/orders/:id
```

**response:**
```json
{
  "order_id": 10,
  "status": "out_for_delivery",
  "items": [
    {
      "inventory_item_id": 1,
      "item_name": "Pizza",
      "quantity": 2
    },
    {
      "inventory_item_id": 2,
      "item_name": "Pasta",
      "quantity": 1
    }
  ]
}
```

---

### 4. inventory alerts

when inventory quantity goes below its threshold, you will see in terminal:
```
Inventory Alert: 'Pizza' is low! Quantity: 2, Threshold: 3
```

check the sidekiq terminal for alerts.

---

## run unit tests

make sure your test db is migrated:

```bash
bin/rails db:migrate RAILS_ENV=test
```

run tests:
```bash
rails test
```

expected output:
```
tests cases should pass 🙏!
```

---