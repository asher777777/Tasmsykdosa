/*
  # Fix business settings uniqueness
  
  1. Changes
    - Ensures only one row exists in business_settings
    - Keeps the most recently updated row
    - Adds constraint to prevent multiple rows
*/

-- Keep only the most recent row and delete others
WITH ranked_settings AS (
  SELECT id,
         ROW_NUMBER() OVER (ORDER BY updated_at DESC NULLS LAST) as rn
  FROM business_settings
)
DELETE FROM business_settings
WHERE id IN (
  SELECT id 
  FROM ranked_settings 
  WHERE rn > 1
);

-- Add constraint to ensure only one row can exist
CREATE UNIQUE INDEX IF NOT EXISTS business_settings_singleton 
ON business_settings ((true));

-- Recreate policies
DROP POLICY IF EXISTS "allow_select" ON business_settings;
DROP POLICY IF EXISTS "allow_write" ON business_settings;

CREATE POLICY "allow_select"
  ON business_settings
  FOR SELECT
  USING (true);

CREATE POLICY "allow_write"
  ON business_settings
  FOR ALL
  USING (true)
  WITH CHECK (true);

-- Ensure exactly one row exists
INSERT INTO business_settings (business_name)
SELECT 'העסק שלי'
WHERE NOT EXISTS (SELECT 1 FROM business_settings);