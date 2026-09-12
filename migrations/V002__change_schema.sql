-- Move price from product_info into product
ALTER TABLE product
ADD COLUMN price DOUBLE PRECISION;

UPDATE product p
SET price = pi.price
FROM product_info pi
WHERE p.id = pi.product_id;


-- Move date_created from orders_date into orders
ALTER TABLE orders
ADD COLUMN date_created DATE DEFAULT CURRENT_DATE;

UPDATE orders o
SET date_created = od.date_created
FROM orders_date od
WHERE o.id = od.order_id;


-- Add primary keys now that ids are stable
ALTER TABLE product
ADD CONSTRAINT pk_product PRIMARY KEY (id);

ALTER TABLE orders
ADD CONSTRAINT pk_orders PRIMARY KEY (id);


-- Enforce referential integrity between order_product and its parents
ALTER TABLE order_product
ADD CONSTRAINT fk_order_product_order
FOREIGN KEY (order_id)
REFERENCES orders(id);

ALTER TABLE order_product
ADD CONSTRAINT fk_order_product_product
FOREIGN KEY (product_id)
REFERENCES product(id);


-- Drop now-redundant staging tables
DROP TABLE product_info;

DROP TABLE orders_date;
