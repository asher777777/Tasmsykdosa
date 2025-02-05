-- Drop ALL existing policies from business_settings
DO $$ 
BEGIN
  DROP POLICY IF EXISTS "Anyone can view business settings" ON business_settings;
  DROP POLICY IF EXISTS "Only admins can modify business settings" ON business_settings;
  DROP POLICY IF EXISTS "business_settings_read_policy" ON business_settings;
  DROP POLICY IF EXISTS "business_settings_write_policy" ON business_settings;
  DROP POLICY IF EXISTS "Enable read access for all users" ON business_settings;
  DROP POLICY IF EXISTS "Enable write access for admins" ON business_settings;
  DROP POLICY IF EXISTS "Enable update access for admins" ON business_settings;
  DROP POLICY IF EXISTS "Enable delete access for admins" ON business_settings;
EXCEPTION WHEN undefined_object THEN NULL;
END $$;

-- Disable RLS temporarily
ALTER TABLE business_settings DISABLE ROW LEVEL SECURITY;

-- Re-enable RLS
ALTER TABLE business_settings ENABLE ROW LEVEL SECURITY;

-- Create simple, permissive policies
CREATE POLICY "public_select"
  ON business_settings
  FOR SELECT
  USING (true);

CREATE POLICY "admin_insert"
  ON business_settings
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
      AND role = 'admin'
    )
  );

CREATE POLICY "admin_update"
  ON business_settings
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
      AND role = 'admin'
    )
  );

CREATE POLICY "admin_delete"
  ON business_settings
  FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
      AND role = 'admin'
    )
  );

-- Grant permissions to authenticated users
GRANT SELECT ON business_settings TO authenticated;
GRANT INSERT, UPDATE, DELETE ON business_settings TO authenticated;