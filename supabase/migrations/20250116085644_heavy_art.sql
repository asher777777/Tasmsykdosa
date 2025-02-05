-- Drop existing policies
DROP POLICY IF EXISTS "Enable read access for all users" ON receipts;
DROP POLICY IF EXISTS "Enable insert for all users" ON receipts;
DROP POLICY IF EXISTS "Enable update for all users" ON receipts;
DROP POLICY IF EXISTS "Enable delete for all users" ON receipts;

-- Create new, more permissive policies
CREATE POLICY "public_read_receipts"
  ON receipts FOR SELECT
  USING (true);

CREATE POLICY "public_insert_receipts"
  ON receipts FOR INSERT
  WITH CHECK (true);

CREATE POLICY "public_update_receipts"
  ON receipts FOR UPDATE
  USING (true)
  WITH CHECK (true);

CREATE POLICY "public_delete_receipts"
  ON receipts FOR DELETE
  USING (true);

-- Grant permissions
GRANT ALL ON receipts TO authenticated;
GRANT SELECT ON receipts TO anon;