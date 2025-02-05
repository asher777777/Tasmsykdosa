/*
  # Fix customers table constraints

  1. Changes
    - Add unique constraint on phone column
    - Update existing policies
    - Add index for better performance

  2. Security
    - Maintain existing RLS policies
*/

-- Add unique constraint on phone
ALTER TABLE customers 
ADD CONSTRAINT customers_phone_key UNIQUE (phone);

-- Add index for better performance
CREATE INDEX IF NOT EXISTS idx_customers_phone 
ON customers(phone);

-- Reset RLS
ALTER TABLE customers DISABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;

-- Recreate policies
DROP POLICY IF EXISTS "Enable read access for all users" ON customers;
DROP POLICY IF EXISTS "Enable write access for all users" ON customers;

CREATE POLICY "Enable read access for all users"
  ON customers
  FOR SELECT
  USING (true);

CREATE POLICY "Enable write access for all users"
  ON customers
  FOR ALL
  USING (true)
  WITH CHECK (true);

-- Grant permissions
GRANT ALL ON customers TO authenticated;
GRANT SELECT ON customers TO anon;