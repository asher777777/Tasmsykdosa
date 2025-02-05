/*
  # Add media support
  
  1. New Tables
    - `media`
      - `id` (uuid, primary key)
      - `file_name` (text)
      - `file_type` (text)
      - `url` (text)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)
      
  2. Security
    - Enable RLS on media table
    - Add policies for authenticated users
*/

-- Create media table
CREATE TABLE IF NOT EXISTS media (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  file_name text NOT NULL,
  file_type text NOT NULL,
  url text NOT NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE media ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "media_read_policy"
  ON media FOR SELECT
  USING (true);

CREATE POLICY "media_write_policy"
  ON media
  FOR ALL
  USING (auth.role() = 'authenticated')
  WITH CHECK (auth.role() = 'authenticated');

-- Add media_id to business_settings
ALTER TABLE business_settings
ADD COLUMN IF NOT EXISTS media_id uuid REFERENCES media(id);