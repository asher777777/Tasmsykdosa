/*
  # Fix orders delete policy

  1. Changes
    - Add explicit delete policy
    - Ensure all operations are allowed for all users
    - Remove unnecessary constraints

  2. Security
    - Allow all users to perform all operations on orders
    - Maintain soft delete functionality
*/

-- Drop all existing policies to start fresh
DROP POLICY IF EXISTS "Enable read access for all users" ON orders;
DROP POLICY IF EXISTS "Enable insert for all users" ON orders;
DROP POLICY IF EXISTS "Enable update for all users" ON orders;

-- Create comprehensive policies
CREATE POLICY "Enable read access for all users"
  ON orders FOR SELECT
  USING (true);

CREATE POLICY "Enable insert for all users"
  ON orders FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Enable update for all users"
  ON orders FOR UPDATE
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Enable delete for all users"
  ON orders FOR DELETE
  USING (true);

-- Drop and recreate the trigger to ensure it works with the new policies
DROP TRIGGER IF EXISTS prevent_order_delete ON orders;

CREATE OR REPLACE FUNCTION handle_order_delete()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE orders 
  SET deleted_at = CURRENT_TIMESTAMP 
  WHERE id = OLD.id;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER prevent_order_delete
  BEFORE DELETE ON orders
  FOR EACH ROW
  EXECUTE FUNCTION handle_order_delete();