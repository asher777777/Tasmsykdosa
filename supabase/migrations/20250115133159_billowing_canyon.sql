-- Drop existing policies if they exist
DO $$ 
BEGIN
  DROP POLICY IF EXISTS "Anyone can view business settings" ON business_settings;
  DROP POLICY IF EXISTS "Only admins can modify business settings" ON business_settings;
  DROP POLICY IF EXISTS "business_settings_read_policy" ON business_settings;
  DROP POLICY IF EXISTS "business_settings_write_policy" ON business_settings;
EXCEPTION WHEN undefined_object THEN NULL;
END $$;

-- Create new policies with better permissions
CREATE POLICY "Enable read access for all users"
  ON business_settings
  FOR SELECT
  USING (true);

CREATE POLICY "Enable write access for admins"
  ON business_settings
  FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
      AND role = 'admin'
    )
  );

CREATE POLICY "Enable update access for admins"
  ON business_settings
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
      AND role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
      AND role = 'admin'
    )
  );

CREATE POLICY "Enable delete access for admins"
  ON business_settings
  FOR DELETE
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
      AND role = 'admin'
    )
  );

-- Ensure default settings exist
INSERT INTO business_settings (business_name)
SELECT 'העסק שלי'
WHERE NOT EXISTS (
  SELECT 1 FROM business_settings
);