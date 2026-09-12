-- Speed up joins from order_product back to orders
CREATE INDEX order_product_order_id_idx ON order_product(order_id);

-- Speed up filtering orders by status and date range
CREATE INDEX orders_status_date_idx ON orders(status, date_created);
