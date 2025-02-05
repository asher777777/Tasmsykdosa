/*
  # Update business settings table

  1. Updates
    - Drop existing policies
    - Update RLS settings
    - Add new policies for better security
    - Ensure default settings exist
*/

-- Drop existing policies if they exist
DO $$ 
BEGIN
  DROP POLICY IF EXISTS "Anyone can view business settings" ON business_settings;
  DROP POLICY IF EXISTS "Only admins can modify business settings" ON business_settings;
EXCEPTION WHEN undefined_object THEN NULL;
END $$;

-- Create policies with better security
CREATE POLICY "Anyone can view business settings"
  ON business_settings
  FOR SELECT
  USING (true);

CREATE POLICY "Only admins can modify business settings"
  ON business_settings
  FOR ALL
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

-- Ensure default settings exist
INSERT INTO business_settings (business_name)
SELECT 'העסק שלי'
WHERE NOT EXISTS (
  SELECT 1 FROM business_settings
);