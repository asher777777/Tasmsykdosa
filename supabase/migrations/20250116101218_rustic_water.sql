-- Add receipt_slug column to orders table
ALTER TABLE orders
ADD COLUMN IF NOT EXISTS receipt_slug text;

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_orders_receipt_slug ON orders(receipt_slug);

-- Add foreign key constraint to ensure receipt_slug exists in receipts table
ALTER TABLE orders
ADD CONSTRAINT fk_receipt_slug
FOREIGN KEY (receipt_slug)
REFERENCES receipts(slug)
ON DELETE SET NULL;

-- Update existing orders with receipt slugs
UPDATE orders o
SET receipt_slug = r.slug
FROM receipts r
WHERE o.receipt_id = r.id
AND o.receipt_slug IS NULL;