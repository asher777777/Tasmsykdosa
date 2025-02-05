-- Reset ALL permissions and policies
DO $$ 
BEGIN
  -- Drop all existing policies
  DROP POLICY IF EXISTS "public_select" ON business_settings;
  DROP POLICY IF EXISTS "admin_insert" ON business_settings;
  DROP POLICY IF EXISTS "admin_update" ON business_settings;
  DROP POLICY IF EXISTS "admin_delete" ON business_settings;
EXCEPTION WHEN undefined_object THEN NULL;
END $$;

-- Disable and re-enable RLS to reset all permissions
ALTER TABLE business_settings DISABLE ROW LEVEL SECURITY;
ALTER TABLE business_settings ENABLE ROW LEVEL SECURITY;

-- Create a single policy for read access
CREATE POLICY "allow_read"
  ON business_settings
  FOR SELECT
  USING (true);

-- Create a single policy for write operations
CREATE POLICY "allow_write"
  ON business_settings
  FOR ALL
  USING (true)
  WITH CHECK (true);

-- Grant basic permissions
GRANT ALL ON business_settings TO authenticated;
GRANT USAGE ON SCHEMA public TO authenticated;

-- Insert default settings if none exist
INSERT INTO business_settings (business_name)
SELECT 'העסק שלי'
WHERE NOT EXISTS (SELECT 1 FROM business_settings);