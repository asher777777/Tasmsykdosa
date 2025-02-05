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
EXCEPTION 
  WHEN OTHERS THEN
    RETURN false;
END;
$$;

-- Function to handle new user registration with robust error handling
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
    VALUES (NEW.id, new_role);
  EXCEPTION 
    WHEN unique_violation THEN
      -- If there's a unique violation, the user role already exists
      -- Update the existing role instead
      UPDATE user_roles 
      SET role = new_role,
          updated_at = CURRENT_TIMESTAMP 
      WHERE user_id = NEW.id;
    WHEN OTHERS THEN
      -- Log other errors but don't fail the transaction
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

-- Ensure user_roles table exists and has correct structure
CREATE TABLE IF NOT EXISTS user_roles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  role text NOT NULL CHECK (role IN ('admin', 'user')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(user_id)
);

-- Create index for faster lookups if it doesn't exist
CREATE INDEX IF NOT EXISTS idx_user_roles_user_id ON user_roles(user_id);

-- Enable RLS
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;

-- Update policies for user_roles with unique names
DO $$ 
BEGIN
  DROP POLICY IF EXISTS "user_roles_select_policy_v5" ON user_roles;
  DROP POLICY IF EXISTS "user_roles_insert_policy_v5" ON user_roles;
  DROP POLICY IF EXISTS "user_roles_update_policy_v5" ON user_roles;
EXCEPTION WHEN undefined_object THEN NULL;
END $$;

-- Create new policies with improved permissions
CREATE POLICY "user_roles_select_policy_v6"
  ON user_roles
  FOR SELECT
  USING (true);

CREATE POLICY "user_roles_insert_policy_v6"
  ON user_roles
  FOR INSERT
  WITH CHECK (
    auth.role() = 'authenticated' OR 
    NOT EXISTS (SELECT 1 FROM user_roles LIMIT 1)
  );

CREATE POLICY "user_roles_update_policy_v6"
  ON user_roles
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
      AND role = 'admin'
    )
  );