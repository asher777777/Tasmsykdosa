-- Drop existing policies and triggers first
DO $$ 
BEGIN
  DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
  DROP FUNCTION IF EXISTS handle_new_user() CASCADE;
  DROP FUNCTION IF EXISTS is_admin() CASCADE;
EXCEPTION WHEN undefined_object THEN NULL;
END $$;

-- Function to check if user is admin with better error handling
CREATE OR REPLACE FUNCTION is_admin()
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- First check if the user is authenticated
  IF auth.uid() IS NULL THEN
    RETURN false;
  END IF;

  -- Then check for admin role
  RETURN EXISTS (
    SELECT 1 
    FROM user_roles 
    WHERE user_id = auth.uid() 
    AND role = 'admin'
  );
EXCEPTION 
  WHEN OTHERS THEN
    -- Log error but return false for safety
    RAISE WARNING 'Error in is_admin check: %', SQLERRM;
    RETURN false;
END;
$$;

-- Function to handle new user registration with comprehensive error handling
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  is_first_user boolean;
  new_role text;
BEGIN
  -- Check if this is the first user with error handling
  BEGIN
    SELECT NOT EXISTS (
      SELECT 1 FROM user_roles LIMIT 1
    ) INTO is_first_user;
  EXCEPTION WHEN OTHERS THEN
    is_first_user := false;
  END;

  -- Determine role
  new_role := CASE WHEN is_first_user THEN 'admin' ELSE 'user' END;

  -- Insert the user role with comprehensive error handling
  BEGIN
    INSERT INTO user_roles (user_id, role)
    VALUES (NEW.id, new_role)
    ON CONFLICT (user_id) 
    DO UPDATE SET 
      role = EXCLUDED.role,
      updated_at = CURRENT_TIMESTAMP;
  EXCEPTION WHEN OTHERS THEN
    -- Log error but don't fail the transaction
    RAISE WARNING 'Error in handle_new_user: %', SQLERRM;
  END;

  RETURN NEW;
END;
$$;

-- Create trigger for new user registration
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();

-- Update policies for user_roles
DO $$ 
BEGIN
  DROP POLICY IF EXISTS "user_roles_select_policy_v6" ON user_roles;
  DROP POLICY IF EXISTS "user_roles_insert_policy_v6" ON user_roles;
  DROP POLICY IF EXISTS "user_roles_update_policy_v6" ON user_roles;
EXCEPTION WHEN undefined_object THEN NULL;
END $$;

-- Create new policies with improved permissions
CREATE POLICY "user_roles_select_policy_v7"
  ON user_roles
  FOR SELECT
  USING (true);

CREATE POLICY "user_roles_insert_policy_v7"
  ON user_roles
  FOR INSERT
  WITH CHECK (
    auth.role() = 'authenticated' OR 
    NOT EXISTS (SELECT 1 FROM user_roles LIMIT 1)
  );

CREATE POLICY "user_roles_update_policy_v7"
  ON user_roles
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
      AND role = 'admin'
    )
  );

-- Ensure all existing users have roles
INSERT INTO user_roles (user_id, role)
SELECT id, 'user'
FROM auth.users
WHERE id NOT IN (SELECT user_id FROM user_roles)
ON CONFLICT (user_id) DO NOTHING;