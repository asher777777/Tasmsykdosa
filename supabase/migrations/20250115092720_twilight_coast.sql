/*
  # Update RLS policies
  
  1. Changes
    - Create auth schema if not exists
    - Enable RLS on all tables
    - Drop all existing policies
    - Create new unified policies for authenticated users
    
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

-- Drop ALL existing policies
DO $$ 
DECLARE
  r RECORD;
BEGIN
  FOR r IN (
    SELECT schemaname, tablename, policyname 
    FROM pg_policies 
    WHERE schemaname = 'public'
  ) LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON %I.%I', 
      r.policyname, r.schemaname, r.tablename);
  END LOOP;
END $$;

-- Create new unified policies for business_settings
CREATE POLICY "business_settings_select_policy" ON business_settings
  FOR SELECT USING (true);

CREATE POLICY "business_settings_modify_policy" ON business_settings
  FOR ALL USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

-- Create new unified policies for customers
CREATE POLICY "customers_select_policy" ON customers
  FOR SELECT USING (true);

CREATE POLICY "customers_modify_policy" ON customers
  FOR ALL USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

-- Create new unified policies for orders
CREATE POLICY "orders_select_policy" ON orders
  FOR SELECT USING (true);

CREATE POLICY "orders_modify_policy" ON orders
  FOR ALL USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

-- Create new unified policies for products
CREATE POLICY "products_select_policy" ON products
  FOR SELECT USING (true);

CREATE POLICY "products_modify_policy" ON products
  FOR ALL USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

-- Create new unified policies for receipts
CREATE POLICY "receipts_select_policy" ON receipts
  FOR SELECT USING (true);

CREATE POLICY "receipts_modify_policy" ON receipts
  FOR ALL USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');