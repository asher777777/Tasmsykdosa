/*
  # Fix business settings RLS policies

  1. Changes
    - Drop existing RLS policies
    - Create new, more permissive policies for business settings
    - Allow anonymous access for select operations
    - Allow authenticated users full access
    
  2. Security
    - Enables public read access
    - Restricts write operations to authenticated users
*/

-- Drop existing policies
DROP POLICY IF EXISTS "Business settings are viewable by everyone" ON business_settings;
DROP POLICY IF EXISTS "Authenticated users can manage business settings" ON business_settings;

-- Create new policies
CREATE POLICY "Enable read access for all users"
  ON business_settings
  FOR SELECT
  USING (true);

CREATE POLICY "Enable insert for authenticated users"
  ON business_settings
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Enable update for authenticated users"
  ON business_settings
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Enable delete for authenticated users"
  ON business_settings
  FOR DELETE
  TO authenticated
  USING (true);

-- Insert default settings if none exist
INSERT INTO business_settings (business_name)
SELECT 'העסק שלי'
WHERE NOT EXISTS (SELECT 1 FROM business_settings);