-- add a new column to demonstrate schema evolution
ALTER TABLE customers ADD COLUMN email VARCHAR(255);

INSERT INTO customers (first_name, last_name, email) VALUES
('pradeep','bhp','pradeep.bhp@gmail.com');
