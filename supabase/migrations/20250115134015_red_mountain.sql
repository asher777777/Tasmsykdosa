-- Reset ALL permissions and policies
DO $$ 
BEGIN
  -- Drop all existing policies
  DROP POLICY IF EXISTS "deny_all" ON business_settings;
EXCEPTION WHEN undefined_object THEN NULL;
END $$;

-- Disable and re-enable RLS
ALTER TABLE business_settings DISABLE ROW LEVEL SECURITY;
ALTER TABLE business_settings ENABLE ROW LEVEL SECURITY;

-- Create basic policies
CREATE POLICY "allow_select"
  ON business_settings
  FOR SELECT
  USING (true);

CREATE POLICY "allow_insert"
  ON business_settings
  FOR INSERT
  WITH CHECK (true);

CREATE POLICY "allow_update"
  ON business_settings
  FOR UPDATE
  USING (true)
  WITH CHECK (true);

CREATE POLICY "allow_delete"
  ON business_settings
  FOR DELETE
  USING (true);

-- Grant permissions
GRANT ALL ON business_settings TO authenticated;
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT SELECT ON business_settings TO anon;

-- Ensure default settings exist
INSERT INTO business_settings (business_name)
SELECT 'העסק שלי'
WHERE NOT EXISTS (SELECT 1 FROM business_settings);