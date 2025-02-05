/*
  # Fix orders RLS policies

  1. Changes
    - Drop existing RLS policies
    - Create new, more permissive policies that allow soft deletes
    - Add policy specifically for handling deleted_at updates

  2. Security
    - Allow all users to read non-deleted orders
    - Allow all users to create orders
    - Allow all users to update orders including soft deletes
*/

-- Drop existing policies
DROP POLICY IF EXISTS "Orders are viewable by everyone" ON orders;
DROP POLICY IF EXISTS "Anyone can create orders" ON orders;
DROP POLICY IF EXISTS "Authenticated users can manage orders" ON orders;

-- Create new policies
CREATE POLICY "Enable read access for all users"
  ON orders FOR SELECT
  USING (deleted_at IS NULL);

CREATE POLICY "Enable insert for all users"
  ON orders FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Enable update for all users"
  ON orders FOR UPDATE
  USING (true)
  WITH CHECK (true);