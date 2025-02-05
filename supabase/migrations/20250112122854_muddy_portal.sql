/*
  # Update products table RLS policies

  1. Security Changes
    - Remove authentication requirement for product management
    - Allow all operations (insert/update/delete) without authentication
    - Maintain public read access
*/

-- Drop existing policies
DROP POLICY IF EXISTS "Products are viewable by everyone" ON products;
DROP POLICY IF EXISTS "Authenticated users can manage products" ON products;

-- Create new, more permissive policies
CREATE POLICY "Enable read access for all users"
  ON products
  FOR SELECT
  USING (true);

CREATE POLICY "Enable insert access for all users"
  ON products
  FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Enable update access for all users"
  ON products
  FOR UPDATE
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Enable delete access for all users"
  ON products
  FOR DELETE
  USING (true);