CREATE TABLE roles (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(40) NOT NULL UNIQUE
);

CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  username VARCHAR(80) NOT NULL UNIQUE,
  full_name VARCHAR(140) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role_id INT NOT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_users_role FOREIGN KEY (role_id) REFERENCES roles(id)
);

CREATE TABLE categories (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE products (
  id INT AUTO_INCREMENT PRIMARY KEY,
  sku VARCHAR(64) NOT NULL UNIQUE,
  name VARCHAR(160) NOT NULL,
  category_id INT NULL,
  size VARCHAR(40) NULL,
  color VARCHAR(60) NULL,
  cost DECIMAL(12,2) NOT NULL DEFAULT 0,
  price DECIMAL(12,2) NOT NULL,
  stock INT NOT NULL DEFAULT 0,
  min_stock INT NOT NULL DEFAULT 0,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_products_category FOREIGN KEY (category_id) REFERENCES categories(id),
  INDEX idx_products_search (sku, name),
  INDEX idx_products_stock (stock, min_stock)
);

CREATE TABLE payment_methods (
  id INT AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(30) NOT NULL UNIQUE,
  name VARCHAR(80) NOT NULL,
  requires_reference TINYINT(1) NOT NULL DEFAULT 0,
  is_active TINYINT(1) NOT NULL DEFAULT 1
);

CREATE TABLE shifts (
  id INT AUTO_INCREMENT PRIMARY KEY,
  opened_by INT NOT NULL,
  closed_by INT NULL,
  opening_cash DECIMAL(12,2) NOT NULL DEFAULT 0,
  expected_cash DECIMAL(12,2) NULL,
  counted_cash DECIMAL(12,2) NULL,
  difference DECIMAL(12,2) NULL,
  status ENUM('OPEN','CLOSED') NOT NULL DEFAULT 'OPEN',
  opened_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  closed_at DATETIME NULL,
  CONSTRAINT fk_shifts_opened_by FOREIGN KEY (opened_by) REFERENCES users(id),
  CONSTRAINT fk_shifts_closed_by FOREIGN KEY (closed_by) REFERENCES users(id),
  INDEX idx_shifts_status (status, opened_at)
);

CREATE TABLE sales (
  id INT AUTO_INCREMENT PRIMARY KEY,
  receipt_number VARCHAR(40) NOT NULL UNIQUE,
  shift_id INT NOT NULL,
  user_id INT NOT NULL,
  customer_name VARCHAR(140) NULL,
  subtotal DECIMAL(12,2) NOT NULL,
  total DECIMAL(12,2) NOT NULL,
  status ENUM('COMPLETED','VOID') NOT NULL DEFAULT 'COMPLETED',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_sales_shift FOREIGN KEY (shift_id) REFERENCES shifts(id),
  CONSTRAINT fk_sales_user FOREIGN KEY (user_id) REFERENCES users(id),
  INDEX idx_sales_created_at (created_at),
  INDEX idx_sales_shift (shift_id)
);

CREATE TABLE sale_items (
  id INT AUTO_INCREMENT PRIMARY KEY,
  sale_id INT NOT NULL,
  product_id INT NOT NULL,
  sku_snapshot VARCHAR(64) NOT NULL,
  name_snapshot VARCHAR(160) NOT NULL,
  size_snapshot VARCHAR(40) NULL,
  color_snapshot VARCHAR(60) NULL,
  quantity INT NOT NULL,
  unit_price DECIMAL(12,2) NOT NULL,
  total DECIMAL(12,2) NOT NULL,
  CONSTRAINT fk_sale_items_sale FOREIGN KEY (sale_id) REFERENCES sales(id),
  CONSTRAINT fk_sale_items_product FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE TABLE sale_payments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  sale_id INT NOT NULL,
  payment_method_id INT NOT NULL,
  amount DECIMAL(12,2) NOT NULL,
  reference VARCHAR(120) NULL,
  CONSTRAINT fk_sale_payments_sale FOREIGN KEY (sale_id) REFERENCES sales(id),
  CONSTRAINT fk_sale_payments_method FOREIGN KEY (payment_method_id) REFERENCES payment_methods(id)
);

CREATE TABLE inventory_movements (
  id INT AUTO_INCREMENT PRIMARY KEY,
  product_id INT NOT NULL,
  sale_id INT NULL,
  user_id INT NOT NULL,
  movement_type ENUM('IN','OUT','ADJUSTMENT','SALE') NOT NULL,
  quantity INT NOT NULL,
  previous_stock INT NOT NULL,
  new_stock INT NOT NULL,
  note VARCHAR(255) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_inventory_product FOREIGN KEY (product_id) REFERENCES products(id),
  CONSTRAINT fk_inventory_sale FOREIGN KEY (sale_id) REFERENCES sales(id),
  CONSTRAINT fk_inventory_user FOREIGN KEY (user_id) REFERENCES users(id),
  INDEX idx_inventory_created_at (created_at)
);

CREATE TABLE cash_closures (
  id INT AUTO_INCREMENT PRIMARY KEY,
  shift_id INT NOT NULL UNIQUE,
  user_id INT NOT NULL,
  expected_cash DECIMAL(12,2) NOT NULL,
  counted_cash DECIMAL(12,2) NOT NULL,
  difference DECIMAL(12,2) NOT NULL,
  notes VARCHAR(255) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_cash_closures_shift FOREIGN KEY (shift_id) REFERENCES shifts(id),
  CONSTRAINT fk_cash_closures_user FOREIGN KEY (user_id) REFERENCES users(id)
);

INSERT INTO roles (name) VALUES
  ('admin'),
  ('supervisor'),
  ('cajero'),
  ('inventario');

INSERT INTO users (username, full_name, password_hash, role_id) VALUES
  ('admin', 'Administrador', 'pbkdf2_sha256$100000$admin_salt_2026$fNMIYd2LwNGvm/HQ/MV25ktTz6qYXU/viKVvWP1qZuo=', (SELECT id FROM roles WHERE name = 'admin')),
  ('supervisor', 'Supervisor', 'pbkdf2_sha256$100000$supervisor_salt_2026$KHbyAWiSFaZ8IF7sBRQq/8ARQoRSDKWhuDQHn4dqj1I=', (SELECT id FROM roles WHERE name = 'supervisor')),
  ('cajero', 'Cajero', 'pbkdf2_sha256$100000$cajero_salt_2026$T5zkJ/iZBrktXffpJCHUK96yV1NKaWLpUYElEPmm+dY=', (SELECT id FROM roles WHERE name = 'cajero')),
  ('inventario', 'Inventario', 'pbkdf2_sha256$100000$inventario_salt_2026$l3FeYp2QET0//L8Yp9Heg5GhhA2Go5MUh9VaN2N3P2w=', (SELECT id FROM roles WHERE name = 'inventario'));

INSERT INTO categories (name) VALUES
  ('Camisetas'),
  ('Pantalonetas'),
  ('Leggings'),
  ('Calzado'),
  ('Accesorios');

INSERT INTO payment_methods (code, name, requires_reference) VALUES
  ('cash', 'Efectivo', 0),
  ('debit', 'Tarjeta debito', 1),
  ('credit', 'Tarjeta credito', 1),
  ('transfer', 'Transferencia', 1);

INSERT INTO products (sku, name, category_id, size, color, cost, price, stock, min_stock) VALUES
  ('CAM-DRY-M-NEG', 'Camiseta dry fit', (SELECT id FROM categories WHERE name = 'Camisetas'), 'M', 'Negro', 25000, 59900, 30, 5),
  ('CAM-DRY-L-AZU', 'Camiseta dry fit', (SELECT id FROM categories WHERE name = 'Camisetas'), 'L', 'Azul', 25000, 59900, 25, 5),
  ('PAN-RUN-M-GRI', 'Pantaloneta running', (SELECT id FROM categories WHERE name = 'Pantalonetas'), 'M', 'Gris', 28000, 69900, 18, 4),
  ('LEG-PRO-S-NEG', 'Legging compresion', (SELECT id FROM categories WHERE name = 'Leggings'), 'S', 'Negro', 42000, 99000, 12, 3),
  ('TEN-URB-40-BLA', 'Tenis entrenamiento', (SELECT id FROM categories WHERE name = 'Calzado'), '40', 'Blanco', 110000, 219900, 8, 2),
  ('BOT-750-ROJ', 'Botella deportiva 750ml', (SELECT id FROM categories WHERE name = 'Accesorios'), NULL, 'Rojo', 12000, 34900, 40, 8);
