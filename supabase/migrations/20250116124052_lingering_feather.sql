/*
  # Add Nedarim API Response Fields

  1. Changes
    - Add nedarim_data JSONB column to receipts table to store Nedarim API response data
    - Add index for better query performance
    - Initialize with empty JSONB object
    - Add less restrictive validation

  2. Security
    - Maintain existing RLS policies
*/

-- Add nedarim_data column to receipts table
ALTER TABLE receipts
ADD COLUMN IF NOT EXISTS nedarim_data JSONB DEFAULT '{}'::jsonb;

-- Create index for better performance when querying nedarim_data
CREATE INDEX IF NOT EXISTS idx_receipts_nedarim_data 
ON receipts USING GIN (nedarim_data);

-- Update existing receipts with empty nedarim_data
UPDATE receipts 
SET nedarim_data = '{}'::jsonb 
WHERE nedarim_data IS NULL;

-- Add validation check for nedarim_data structure
ALTER TABLE receipts
ADD CONSTRAINT valid_nedarim_data
CHECK (
  nedarim_data IS NULL OR 
  jsonb_typeof(nedarim_data) = 'object'
);