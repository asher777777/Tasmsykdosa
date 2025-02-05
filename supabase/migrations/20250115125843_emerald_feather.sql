-- Drop existing policies first
DO $$ 
BEGIN
  -- Drop policies from business_settings
  DROP POLICY IF EXISTS "Only admins can modify business settings" ON business_settings;
  DROP POLICY IF EXISTS "Anyone can view business settings" ON business_settings;
  DROP POLICY IF EXISTS "business_settings_read_policy" ON business_settings;
  DROP POLICY IF EXISTS "business_settings_write_policy" ON business_settings;
  
  -- Drop policies from orders
  DROP POLICY IF EXISTS "Only admins can modify orders" ON orders;
  DROP POLICY IF EXISTS "Anyone can view orders" ON orders;
  DROP POLICY IF EXISTS "orders_read_policy" ON orders;
  DROP POLICY IF EXISTS "orders_write_policy" ON orders;
  
  -- Drop policies from products
  DROP POLICY IF EXISTS "Only admins can modify products" ON products;
  DROP POLICY IF EXISTS "Anyone can view products" ON products;
  DROP POLICY IF EXISTS "products_read_policy" ON products;
  DROP POLICY IF EXISTS "products_write_policy" ON products;
  
  -- Drop policies from customers
  DROP POLICY IF EXISTS "Only admins can modify customers" ON customers;
  DROP POLICY IF EXISTS "Anyone can view customers" ON customers;
  DROP POLICY IF EXISTS "customers_read_policy" ON customers;
  DROP POLICY IF EXISTS "customers_write_policy" ON customers;

  -- Drop policies from user_roles
  DROP POLICY IF EXISTS "Enable read access for all users" ON user_roles;
  DROP POLICY IF EXISTS "Enable insert for authenticated users" ON user_roles;
  DROP POLICY IF EXISTS "Enable update for admins" ON user_roles;
  DROP POLICY IF EXISTS "Users can view their own role" ON user_roles;
  DROP POLICY IF EXISTS "Admins can manage all roles" ON user_roles;
EXCEPTION WHEN undefined_object THEN NULL;
END $$;

-- Now create new policies
CREATE POLICY "user_roles_read_policy"
  ON user_roles
  FOR SELECT
  USING (true);

CREATE POLICY "user_roles_insert_policy"
  ON user_roles
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "user_roles_update_policy"
  ON user_roles
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
      AND role = 'admin'
    )
  );

-- Create policies for other tables
CREATE POLICY "business_settings_read_policy"
  ON business_settings
  FOR SELECT
  USING (true);

CREATE POLICY "business_settings_write_policy"
  ON business_settings
  FOR ALL
  USING (is_admin())
  WITH CHECK (is_admin());

CREATE POLICY "orders_read_policy"
  ON orders
  FOR SELECT
  USING (true);

CREATE POLICY "orders_write_policy"
  ON orders
  FOR ALL
  USING (is_admin())
  WITH CHECK (is_admin());

CREATE POLICY "products_read_policy"
  ON products
  FOR SELECT
  USING (true);

CREATE POLICY "products_write_policy"
  ON products
  FOR ALL
  USING (is_admin())
  WITH CHECK (is_admin());

CREATE POLICY "customers_read_policy"
  ON customers
  FOR SELECT
  USING (true);

CREATE POLICY "customers_write_policy"
  ON customers
  FOR ALL
  USING (is_admin())
  WITH CHECK (is_admin());