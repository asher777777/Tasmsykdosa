/*
  # Add business settings table

  1. New Tables
    - business_settings
      - id (uuid, primary key)
      - logo_url (text)
      - business_name (text)
      - vat_number (text)
      - phone (text)
      - created_at (timestamptz)
      - updated_at (timestamptz)

  2. Security
    - Enable RLS
    - Add policies for authenticated users
*/

-- Create the business_settings table if it doesn't exist
CREATE TABLE IF NOT EXISTS business_settings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  logo_url text,
  business_name text NOT NULL,
  vat_number text,
  phone text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS if not already enabled
ALTER TABLE business_settings ENABLE ROW LEVEL SECURITY;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Business settings are viewable by everyone" ON business_settings;
DROP POLICY IF EXISTS "Authenticated users can manage business settings" ON business_settings;

-- Create new policies
CREATE POLICY "Business settings are viewable by everyone"
  ON business_settings FOR SELECT
  USING (true);

CREATE POLICY "Authenticated users can manage business settings"
  ON business_settings
  FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);