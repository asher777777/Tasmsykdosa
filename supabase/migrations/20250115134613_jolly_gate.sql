/*
  # Make business settings editable by everyone
  
  1. Changes
    - Resets all existing policies
    - Creates new permissive policies for all operations
    - Maintains singleton constraint
    - Ensures default settings exist
*/

-- First, clean up any duplicate rows keeping only the most recently updated one
WITH ranked_settings AS (
  SELECT id,
         ROW_NUMBER() OVER (ORDER BY updated_at DESC NULLS LAST, created_at DESC NULLS LAST) as rn
  FROM business_settings
)
DELETE FROM business_settings
WHERE id IN (
  SELECT id 
  FROM ranked_settings 
  WHERE rn > 1
);

-- Drop existing singleton constraint if it exists
DROP INDEX IF EXISTS business_settings_singleton;

-- Create a new singleton constraint
CREATE UNIQUE INDEX business_settings_singleton ON business_settings ((true));

-- Reset RLS
ALTER TABLE business_settings DISABLE ROW LEVEL SECURITY;
ALTER TABLE business_settings ENABLE ROW LEVEL SECURITY;

-- Drop all existing policies
DROP POLICY IF EXISTS "allow_read" ON business_settings;
DROP POLICY IF EXISTS "allow_write" ON business_settings;

-- Create new permissive policies
CREATE POLICY "enable_read_for_all"
  ON business_settings
  FOR SELECT
  USING (true);

CREATE POLICY "enable_write_for_all"
  ON business_settings
  FOR ALL
  USING (true)
  WITH CHECK (true);

-- Grant appropriate permissions
GRANT ALL ON business_settings TO public;
GRANT ALL ON business_settings TO anon;
GRANT ALL ON business_settings TO authenticated;

-- Ensure exactly one row exists with default values
INSERT INTO business_settings (business_name)
SELECT 'העסק שלי'
WHERE NOT EXISTS (SELECT 1 FROM business_settings);