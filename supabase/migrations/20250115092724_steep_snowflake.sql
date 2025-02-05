/*
  # Update RLS policies for all tables

  1. Changes
    - Drop existing policies
    - Create new unified policies for all tables
    - Enable RLS on all tables
    - Add auth schema if not exists

  2. Security
    - All tables have RLS enabled
    - Read access is public
    - Write access requires authentication
*/

-- Create auth schema if not exists
CREATE SCHEMA IF NOT EXISTS auth;

-- Enable RLS on all tables
ALTER TABLE business_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE receipts ENABLE ROW LEVEL SECURITY;

-- Drop existing policies
DROP POLICY IF EXISTS "Enable read access for all users" ON business_settings;
DROP POLICY IF EXISTS "Enable write access for authenticated users" ON business_settings;
DROP POLICY IF EXISTS "Enable read access for all users" ON customers;
DROP POLICY IF EXISTS "Enable write access for authenticated users" ON customers;
DROP POLICY IF EXISTS "Enable read access for all users" ON orders;
DROP POLICY IF EXISTS "Enable write access for authenticated users" ON orders;
DROP POLICY IF EXISTS "Enable read access for all users" ON products;
DROP POLICY IF EXISTS "Enable write access for authenticated users" ON products;
DROP POLICY IF EXISTS "Enable read access for all users" ON receipts;
DROP POLICY IF EXISTS "Enable write access for authenticated users" ON receipts;

-- Create new policies with unique names for business_settings
CREATE POLICY "business_settings_read_policy"
  ON business_settings FOR SELECT
  USING (true);

CREATE POLICY "business_settings_write_policy"
  ON business_settings
  FOR ALL
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

-- Create new policies with unique names for customers
CREATE POLICY "customers_read_policy"
  ON customers FOR SELECT
  USING (true);

CREATE POLICY "customers_write_policy"
  ON customers
  FOR ALL
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

-- Create new policies with unique names for orders
CREATE POLICY "orders_read_policy"
  ON orders FOR SELECT
  USING (true);

CREATE POLICY "orders_write_policy"
  ON orders
  FOR ALL
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

-- Create new policies with unique names for products
CREATE POLICY "products_read_policy"
  ON products FOR SELECT
  USING (true);

CREATE POLICY "products_write_policy"
  ON products
  FOR ALL
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

-- Create new policies with unique names for receipts
CREATE POLICY "receipts_read_policy"
  ON receipts FOR SELECT
  USING (true);

CREATE POLICY "receipts_write_policy"
  ON receipts
  FOR ALL
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');