-- Drop existing policies and triggers first
DO $$ 
BEGIN
  DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
  DROP FUNCTION IF EXISTS handle_new_user() CASCADE;
  DROP FUNCTION IF EXISTS is_admin() CASCADE;
EXCEPTION WHEN undefined_object THEN NULL;
END $$;

-- Function to check if user is admin
CREATE OR REPLACE FUNCTION is_admin()
RETURNS boolean
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM user_roles
    WHERE user_id = auth.uid()
    AND role = 'admin'
  );
END;
$$;

-- Function to handle new user registration with better error handling
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  is_first_user boolean;
BEGIN
  -- Check if this is the first user
  SELECT NOT EXISTS (
    SELECT 1 FROM user_roles
  ) INTO is_first_user;

  -- Insert the user role with explicit error handling
  BEGIN
    INSERT INTO user_roles (user_id, role)
    VALUES (
      NEW.id,
      CASE WHEN is_first_user THEN 'admin' ELSE 'user' END
    );
  EXCEPTION WHEN unique_violation THEN
    -- If there's a unique violation, the user role already exists
    -- We can safely ignore this
    NULL;
  WHEN OTHERS THEN
    -- Log other errors but don't fail the transaction
    RAISE WARNING 'Error creating user role: %', SQLERRM;
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
  DROP POLICY IF EXISTS "user_roles_select_policy_v3" ON user_roles;
  DROP POLICY IF EXISTS "user_roles_insert_policy_v3" ON user_roles;
  DROP POLICY IF EXISTS "user_roles_update_policy_v3" ON user_roles;
EXCEPTION WHEN undefined_object THEN NULL;
END $$;

-- Create new policies with better permissions
CREATE POLICY "user_roles_select_policy_v4"
  ON user_roles
  FOR SELECT
  USING (true);

CREATE POLICY "user_roles_insert_policy_v4"
  ON user_roles
  FOR INSERT
  WITH CHECK (true);

CREATE POLICY "user_roles_update_policy_v4"
  ON user_roles
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
      AND role = 'admin'
    )
  );