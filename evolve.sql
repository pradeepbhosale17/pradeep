-- add a new column to demonstrate schema evolution
ALTER TABLE customers ADD COLUMN email VARCHAR(255);

-- Insert multiple records
INSERT INTO customers (first_name, last_name, email) VALUES
('Pradeep', 'Bhp', 'pradeep.bhp@gmail.com'),
('Sanika', 'Patil', 'sanika.patil@example.com'),
('Ravi', 'Kumar', 'ravi.kumar@example.com'),
('Sneha', 'Joshi', 'sneha.joshi@example.com'),
('Amit', 'Sharma', 'amit.sharma@example.com');
