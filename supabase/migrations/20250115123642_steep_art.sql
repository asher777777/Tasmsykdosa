/*
  # Add user roles and global permissions

  1. New Tables
    - `user_roles` - Stores user role assignments
      - `user_id` (uuid, references auth.users)
      - `role` (text, either 'admin' or 'user')
      - `created_at` (timestamptz)
  
  2. Changes
    - Add role-based policies to existing tables
    - Make business settings globally accessible
    - Add default admin user creation function
*/

-- Create user_roles table
CREATE TABLE IF NOT EXISTS user_roles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  role text NOT NULL CHECK (role IN ('admin', 'user')),
  created_at timestamptz DEFAULT now(),
  UNIQUE(user_id)
);

-- Enable RLS
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;

-- Create policies for user_roles
CREATE POLICY "Users can view their own role"
  ON user_roles
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Admins can manage all roles"
  ON user_roles
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
      AND role = 'admin'
    )
  );

-- Function to check if user is admin
CREATE OR REPLACE FUNCTION is_admin()
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM user_roles
    WHERE user_id = auth.uid()
    AND role = 'admin'
  );
END;
$$;

-- Function to automatically assign admin role to first user
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM user_roles LIMIT 1) THEN
    -- First user gets admin role
    INSERT INTO user_roles (user_id, role)
    VALUES (NEW.id, 'admin');
  ELSE
    -- Subsequent users get regular user role
    INSERT INTO user_roles (user_id, role)
    VALUES (NEW.id, 'user');
  END IF;
  RETURN NEW;
END;
$$;

-- Create trigger for new user registration
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();

-- Update business_settings policies to be globally accessible
DROP POLICY IF EXISTS "business_settings_read_policy" ON business_settings;
DROP POLICY IF EXISTS "business_settings_write_policy" ON business_settings;

CREATE POLICY "Anyone can view business settings"
  ON business_settings
  FOR SELECT
  USING (true);

CREATE POLICY "Only admins can modify business settings"
  ON business_settings
  FOR ALL
  USING (is_admin())
  WITH CHECK (is_admin());

-- Update orders policies
DROP POLICY IF EXISTS "orders_read_policy" ON orders;
DROP POLICY IF EXISTS "orders_write_policy" ON orders;

CREATE POLICY "Anyone can view orders"
  ON orders
  FOR SELECT
  USING (true);

CREATE POLICY "Anyone can create orders"
  ON orders
  FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Only admins can modify orders"
  ON orders
  FOR UPDATE
  USING (is_admin())
  WITH CHECK (is_admin());

-- Update products policies
DROP POLICY IF EXISTS "products_read_policy" ON products;
DROP POLICY IF EXISTS "products_write_policy" ON products;

CREATE POLICY "Anyone can view products"
  ON products
  FOR SELECT
  USING (true);

CREATE POLICY "Only admins can modify products"
  ON products
  FOR ALL
  USING (is_admin())
  WITH CHECK (is_admin());

-- Update customers policies
DROP POLICY IF EXISTS "customers_read_policy" ON customers;
DROP POLICY IF EXISTS "customers_write_policy" ON customers;

CREATE POLICY "Anyone can view customers"
  ON customers
  FOR SELECT
  USING (true);

CREATE POLICY "Anyone can create customers"
  ON customers
  FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Only admins can modify customers"
  ON customers
  FOR UPDATE
  USING (is_admin())
  WITH CHECK (is_admin());