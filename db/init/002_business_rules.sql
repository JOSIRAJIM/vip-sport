CREATE TABLE customers (
  id INT AUTO_INCREMENT PRIMARY KEY,
  document_type VARCHAR(20) NULL,
  document_number VARCHAR(40) NULL,
  full_name VARCHAR(160) NOT NULL,
  phone VARCHAR(40) NULL,
  email VARCHAR(140) NULL,
  address VARCHAR(180) NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uq_customers_document (document_type, document_number),
  INDEX idx_customers_search (full_name, document_number, phone)
);

CREATE TABLE discounts (
  id INT AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(40) NOT NULL UNIQUE,
  name VARCHAR(120) NOT NULL,
  discount_type ENUM('PERCENT','FIXED') NOT NULL,
  value DECIMAL(12,2) NOT NULL,
  min_subtotal DECIMAL(12,2) NOT NULL DEFAULT 0,
  starts_at DATETIME NULL,
  ends_at DATETIME NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_by INT NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_discounts_created_by FOREIGN KEY (created_by) REFERENCES users(id),
  INDEX idx_discounts_active (is_active, starts_at, ends_at)
);

CREATE TABLE taxes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(40) NOT NULL UNIQUE,
  name VARCHAR(120) NOT NULL,
  rate DECIMAL(7,4) NOT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

ALTER TABLE sales
  ADD COLUMN customer_id INT NULL AFTER user_id,
  ADD COLUMN discount_id INT NULL AFTER customer_name,
  ADD COLUMN discount_code_snapshot VARCHAR(40) NULL AFTER discount_id,
  ADD COLUMN discount_name_snapshot VARCHAR(120) NULL AFTER discount_code_snapshot,
  ADD COLUMN discount_type_snapshot VARCHAR(20) NULL AFTER discount_name_snapshot,
  ADD COLUMN discount_value_snapshot DECIMAL(12,2) NULL AFTER discount_type_snapshot,
  ADD COLUMN discount_total DECIMAL(12,2) NOT NULL DEFAULT 0 AFTER subtotal,
  ADD COLUMN tax_total DECIMAL(12,2) NOT NULL DEFAULT 0 AFTER discount_total,
  ADD CONSTRAINT fk_sales_customer FOREIGN KEY (customer_id) REFERENCES customers(id),
  ADD CONSTRAINT fk_sales_discount FOREIGN KEY (discount_id) REFERENCES discounts(id);

ALTER TABLE sale_items
  ADD COLUMN returned_quantity INT NOT NULL DEFAULT 0 AFTER quantity;

ALTER TABLE inventory_movements
  MODIFY movement_type ENUM('IN','OUT','ADJUSTMENT','SALE','RETURN') NOT NULL;

CREATE TABLE returns (
  id INT AUTO_INCREMENT PRIMARY KEY,
  return_number VARCHAR(40) NOT NULL UNIQUE,
  sale_id INT NOT NULL,
  shift_id INT NOT NULL,
  user_id INT NOT NULL,
  customer_id INT NULL,
  total DECIMAL(12,2) NOT NULL,
  reason VARCHAR(255) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_returns_sale FOREIGN KEY (sale_id) REFERENCES sales(id),
  CONSTRAINT fk_returns_shift FOREIGN KEY (shift_id) REFERENCES shifts(id),
  CONSTRAINT fk_returns_user FOREIGN KEY (user_id) REFERENCES users(id),
  CONSTRAINT fk_returns_customer FOREIGN KEY (customer_id) REFERENCES customers(id),
  INDEX idx_returns_created_at (created_at)
);

CREATE TABLE return_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  return_id INT NOT NULL,
  sale_item_id INT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL,
  unit_price DECIMAL(12,2) NOT NULL,
  total DECIMAL(12,2) NOT NULL,
  CONSTRAINT fk_return_items_return FOREIGN KEY (return_id) REFERENCES returns(id),
  CONSTRAINT fk_return_items_sale_item FOREIGN KEY (sale_item_id) REFERENCES sale_items(id),
  CONSTRAINT fk_return_items_product FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE TABLE credit_notes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  note_number VARCHAR(40) NOT NULL UNIQUE,
  return_id INT NOT NULL UNIQUE,
  customer_id INT NULL,
  amount DECIMAL(12,2) NOT NULL,
  remaining_amount DECIMAL(12,2) NOT NULL,
  status ENUM('OPEN','REDEEMED','CANCELLED') NOT NULL DEFAULT 'OPEN',
  issued_by INT NOT NULL,
  redeemed_sale_id INT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  redeemed_at DATETIME NULL,
  CONSTRAINT fk_credit_notes_return FOREIGN KEY (return_id) REFERENCES returns(id),
  CONSTRAINT fk_credit_notes_customer FOREIGN KEY (customer_id) REFERENCES customers(id),
  CONSTRAINT fk_credit_notes_issued_by FOREIGN KEY (issued_by) REFERENCES users(id),
  CONSTRAINT fk_credit_notes_sale FOREIGN KEY (redeemed_sale_id) REFERENCES sales(id),
  INDEX idx_credit_notes_status (status, note_number)
);

ALTER TABLE sale_payments
  ADD COLUMN credit_note_id INT NULL AFTER reference,
  ADD CONSTRAINT fk_sale_payments_credit_note FOREIGN KEY (credit_note_id) REFERENCES credit_notes(id);

INSERT INTO payment_methods (code, name, requires_reference) VALUES
  ('credit_note', 'Nota credito', 1);

INSERT INTO taxes (code, name, rate, is_active) VALUES
  ('IVA19', 'IVA 19%', 19.0000, 1),
  ('IVA0', 'Sin impuesto', 0.0000, 1);

INSERT INTO discounts (code, name, discount_type, value, min_subtotal, created_by) VALUES
  ('BIENVENIDA10', 'Descuento bienvenida 10%', 'PERCENT', 10.00, 0, (SELECT id FROM users WHERE username = 'admin'));
