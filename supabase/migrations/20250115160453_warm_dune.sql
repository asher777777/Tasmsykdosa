/*
  # Add authentication fields to business_settings

  1. Changes
    - Add username column
    - Add password column
    - Add updated_at trigger
  
  2. Security
    - No constraints on username/password to allow flexibility
*/

-- Add new columns if they don't exist
ALTER TABLE business_settings 
ADD COLUMN IF NOT EXISTS username text,
ADD COLUMN IF NOT EXISTS password text;

-- Create or replace function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger for updated_at if it doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_trigger 
    WHERE tgname = 'set_updated_at' 
    AND tgrelid = 'business_settings'::regclass
  ) THEN
    CREATE TRIGGER set_updated_at
      BEFORE UPDATE ON business_settings
      FOR EACH ROW
      EXECUTE FUNCTION update_updated_at_column();
  END IF;
END $$;