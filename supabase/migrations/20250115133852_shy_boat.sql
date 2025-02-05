-- Remove ALL permissions and policies
DO $$ 
BEGIN
  -- Drop all existing policies
  DROP POLICY IF EXISTS "allow_read" ON business_settings;
  DROP POLICY IF EXISTS "allow_write" ON business_settings;
  DROP POLICY IF EXISTS "public_select" ON business_settings;
  DROP POLICY IF EXISTS "admin_insert" ON business_settings;
  DROP POLICY IF EXISTS "admin_update" ON business_settings;
  DROP POLICY IF EXISTS "admin_delete" ON business_settings;
EXCEPTION WHEN undefined_object THEN NULL;
END $$;

-- Disable and re-enable RLS to reset all permissions
ALTER TABLE business_settings DISABLE ROW LEVEL SECURITY;
ALTER TABLE business_settings ENABLE ROW LEVEL SECURITY;

-- Revoke all permissions
REVOKE ALL ON business_settings FROM authenticated;
REVOKE ALL ON business_settings FROM anon;

-- Create restrictive policy that denies all access
CREATE POLICY "deny_all"
  ON business_settings
  FOR ALL
  USING (false)
  WITH CHECK (false);