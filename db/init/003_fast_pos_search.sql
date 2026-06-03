ALTER TABLE products
  ADD COLUMN IF NOT EXISTS reference VARCHAR(80) NULL AFTER sku,
  ADD COLUMN IF NOT EXISTS barcode VARCHAR(80) NULL AFTER reference;

CREATE UNIQUE INDEX IF NOT EXISTS uq_products_barcode ON products (barcode);
CREATE INDEX IF NOT EXISTS idx_products_fast_search ON products (sku, reference, barcode, name);

UPDATE products SET reference = 'CAM-DRY', barcode = '770000000001' WHERE sku = 'CAM-DRY-M-NEG' AND barcode IS NULL;
UPDATE products SET reference = 'CAM-DRY', barcode = '770000000002' WHERE sku = 'CAM-DRY-L-AZU' AND barcode IS NULL;
UPDATE products SET reference = 'PAN-RUN', barcode = '770000000003' WHERE sku = 'PAN-RUN-M-GRI' AND barcode IS NULL;
UPDATE products SET reference = 'LEG-PRO', barcode = '770000000004' WHERE sku = 'LEG-PRO-S-NEG' AND barcode IS NULL;
UPDATE products SET reference = 'TEN-URB', barcode = '770000000005' WHERE sku = 'TEN-URB-40-BLA' AND barcode IS NULL;
UPDATE products SET reference = 'BOT-750', barcode = '770000000006' WHERE sku = 'BOT-750-ROJ' AND barcode IS NULL;
