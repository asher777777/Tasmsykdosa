-- Drop the email constraint
ALTER TABLE business_settings DROP CONSTRAINT IF EXISTS valid_email;

-- Ensure we still have our singleton constraint and policies
CREATE UNIQUE INDEX IF NOT EXISTS business_settings_singleton ON business_settings ((true));

-- Reset RLS
ALTER TABLE business_settings DISABLE ROW LEVEL SECURITY;
ALTER TABLE business_settings ENABLE ROW LEVEL SECURITY;

-- Recreate policies
DROP POLICY IF EXISTS "enable_read_for_all" ON business_settings;
DROP POLICY IF EXISTS "enable_write_for_all" ON business_settings;

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