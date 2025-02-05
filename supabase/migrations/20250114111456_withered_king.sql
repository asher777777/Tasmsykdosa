/*
  # Add order protection

  1. Changes
    - Add soft delete column to orders table
    - Add trigger to prevent hard deletes
    - Update RLS policies to respect soft deletes

  2. Security
    - Orders can only be soft deleted
    - Queries will exclude soft deleted orders by default
*/

-- Add soft delete column
ALTER TABLE orders 
ADD COLUMN IF NOT EXISTS deleted_at timestamptz DEFAULT NULL;

-- Create function to handle soft deletes
CREATE OR REPLACE FUNCTION handle_order_delete()
RETURNS TRIGGER AS $$
BEGIN
  -- Instead of deleting, update the deleted_at timestamp
  UPDATE orders 
  SET deleted_at = CURRENT_TIMESTAMP 
  WHERE id = OLD.id;
  
  -- Prevent the actual delete
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for soft deletes
DROP TRIGGER IF EXISTS prevent_order_delete ON orders;
CREATE TRIGGER prevent_order_delete
  BEFORE DELETE ON orders
  FOR EACH ROW
  EXECUTE FUNCTION handle_order_delete();

-- Update existing policies to exclude soft deleted records
DROP POLICY IF EXISTS "Orders are viewable by everyone" ON orders;
CREATE POLICY "Orders are viewable by everyone"
  ON orders
  FOR SELECT
  USING (deleted_at IS NULL);

DROP POLICY IF EXISTS "Anyone can create orders" ON orders;
CREATE POLICY "Anyone can create orders"
  ON orders
  FOR INSERT
  WITH CHECK (true);

DROP POLICY IF EXISTS "Authenticated users can manage orders" ON orders;
CREATE POLICY "Authenticated users can manage orders"
  ON orders
  FOR UPDATE
  USING (deleted_at IS NULL)
  WITH CHECK (deleted_at IS NULL);