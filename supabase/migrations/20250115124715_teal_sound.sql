/*
  # Fix user roles and permissions

  1. New Tables
    - `user_roles` table for storing user roles
      - `id` (uuid, primary key)
      - `user_id` (uuid, references auth.users)
      - `role` (text, check constraint for 'admin' or 'user')
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)

  2. Security
    - Enable RLS on user_roles table
    - Add policies for read/write access
    - Update admin check function
    - Create trigger for new user registration

  3. Changes
    - First registered user gets admin role
    - Subsequent users get regular user role
*/

-- Create user_roles table if it doesn't exist
CREATE TABLE IF NOT EXISTS user_roles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES auth.users(id) ON DELETE CASCADE,
  role text NOT NULL CHECK (role IN ('admin', 'user')),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  UNIQUE(user_id)
);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_user_roles_user_id ON user_roles(user_id);

-- Enable RLS
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;

-- Create policies for user_roles
DO $$ BEGIN
  DROP POLICY IF EXISTS "Enable read access for all users" ON user_roles;
  DROP POLICY IF EXISTS "Enable insert for authenticated users" ON user_roles;
  DROP POLICY IF EXISTS "Enable update for admins" ON user_roles;
EXCEPTION WHEN undefined_object THEN NULL;
END $$;

CREATE POLICY "Enable read access for all users"
  ON user_roles
  FOR SELECT
  USING (true);

CREATE POLICY "Enable insert for authenticated users"
  ON user_roles
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Enable update for admins"
  ON user_roles
  FOR UPDATE
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
      AND role = 'admin'
    )
  );

-- Update admin check function without dropping it
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

-- Drop and recreate trigger and handler function
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS handle_new_user() CASCADE;

-- Create new user handler function
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- First user gets admin role, subsequent users get regular user role
  INSERT INTO user_roles (user_id, role)
  VALUES (
    NEW.id,
    CASE WHEN NOT EXISTS (SELECT 1 FROM user_roles LIMIT 1)
      THEN 'admin'
      ELSE 'user'
    END
  );
  RETURN NEW;
END;
$$;

-- Create trigger for new user registration
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();

-- Update timestamps function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Add updated_at trigger
DROP TRIGGER IF EXISTS update_user_roles_updated_at ON user_roles;
CREATE TRIGGER update_user_roles_updated_at
  BEFORE UPDATE ON user_roles
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();