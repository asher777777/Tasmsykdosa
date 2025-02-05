-- Add current user permissions
DO $$ 
BEGIN
  -- Drop existing policies
  DROP POLICY IF EXISTS "allow_read" ON business_settings;
  DROP POLICY IF EXISTS "allow_write" ON business_settings;
EXCEPTION WHEN undefined_object THEN NULL;
END $$;

-- Create new policies
CREATE POLICY "allow_read"
  ON business_settings
  FOR SELECT
  USING (true);

CREATE POLICY "allow_write"
  ON business_settings
  FOR ALL
  USING (auth.uid() IS NOT NULL)
  WITH CHECK (auth.uid() IS NOT NULL);

-- Grant permissions
GRANT ALL ON business_settings TO authenticated;
GRANT USAGE ON SCHEMA public TO authenticated;