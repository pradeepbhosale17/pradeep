-- initialize a simple inventory database for Debezium demo

CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(255),
    last_name VARCHAR(255)
);

INSERT INTO customers (first_name, last_name) VALUES
('John','Doe'),
('Jane','Doe');
