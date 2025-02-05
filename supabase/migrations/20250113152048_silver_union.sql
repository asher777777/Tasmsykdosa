/*
  # Fix receipts table RLS policies

  1. Changes
    - Drop existing RLS policies for receipts table
    - Create new, more permissive policies for receipts table
    - Allow anonymous access for receipt creation and viewing
*/

-- Drop existing policies
DROP POLICY IF EXISTS "Enable read access for all users" ON receipts;
DROP POLICY IF EXISTS "Enable insert for authenticated users" ON receipts;
DROP POLICY IF EXISTS "Enable update for authenticated users" ON receipts;

-- Create new policies
CREATE POLICY "Enable read access for all users"
  ON receipts FOR SELECT
  USING (true);

CREATE POLICY "Enable insert for all users"
  ON receipts FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Enable update for all users"
  ON receipts FOR UPDATE
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Enable delete for all users"
  ON receipts FOR DELETE
  USING (true);

-- Make receipt_number nullable and remove constraint
ALTER TABLE receipts ALTER COLUMN receipt_number DROP NOT NULL;
ALTER TABLE receipts DROP CONSTRAINT IF EXISTS valid_receipt_number;