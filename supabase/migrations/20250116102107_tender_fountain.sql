-- Drop the foreign key constraint since it's too restrictive
ALTER TABLE orders
DROP CONSTRAINT IF EXISTS fk_receipt_slug;

-- Make receipt_slug nullable and remove the foreign key constraint
ALTER TABLE orders
ALTER COLUMN receipt_slug DROP NOT NULL;

-- Create index for faster lookups if it doesn't exist
CREATE INDEX IF NOT EXISTS idx_orders_receipt_slug ON orders(receipt_slug);

-- Create trigger to update receipt_slug when receipt_id changes
CREATE OR REPLACE FUNCTION update_order_receipt_slug()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.receipt_id IS NOT NULL THEN
    SELECT slug INTO NEW.receipt_slug
    FROM receipts
    WHERE id = NEW.receipt_id;
  END IF;
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger
DROP TRIGGER IF EXISTS update_order_receipt_slug_trigger ON orders;
CREATE TRIGGER update_order_receipt_slug_trigger
  BEFORE UPDATE ON orders
  FOR EACH ROW
  WHEN (NEW.receipt_id IS DISTINCT FROM OLD.receipt_id)
  EXECUTE FUNCTION update_order_receipt_slug();

-- Update existing orders with receipt slugs
UPDATE orders o
SET receipt_slug = r.slug
FROM receipts r
WHERE o.receipt_id = r.id
AND o.receipt_slug IS NULL;