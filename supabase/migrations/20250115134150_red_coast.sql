/*
  # Reset business settings permissions
  
  1. Changes
    - Resets all policies on business_settings table
    - Creates simple read/write policies
    - Grants necessary permissions
    - Ensures default settings exist
*/

-- Drop existing policies
DROP POLICY IF EXISTS "allow_select" ON business_settings;
DROP POLICY IF EXISTS "allow_insert" ON business_settings;
DROP POLICY IF EXISTS "allow_update" ON business_settings;
DROP POLICY IF EXISTS "allow_delete" ON business_settings;

-- Create basic policies
CREATE POLICY "allow_select"
  ON business_settings
  FOR SELECT
  USING (true);

CREATE POLICY "allow_write"
  ON business_settings
  FOR ALL
  USING (true)
  WITH CHECK (true);

-- Grant permissions
GRANT ALL ON business_settings TO authenticated;
GRANT SELECT ON business_settings TO anon;

-- Ensure default settings exist
INSERT INTO business_settings (business_name)
VALUES ('העסק שלי')
ON CONFLICT DO NOTHING;