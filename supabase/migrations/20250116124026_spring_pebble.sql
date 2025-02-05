/*
  # Add Nedarim API Response Fields

  1. Changes
    - Add nedarim_data JSONB column to receipts table to store Nedarim API response data
    - Add validation for required fields
    - Add indexes for better query performance

  2. Security
    - Maintain existing RLS policies
*/

-- Add nedarim_data column to receipts table
ALTER TABLE receipts
ADD COLUMN IF NOT EXISTS nedarim_data JSONB DEFAULT '{}'::jsonb;

-- Create index for better performance when querying nedarim_data
CREATE INDEX IF NOT EXISTS idx_receipts_nedarim_data 
ON receipts USING GIN (nedarim_data);

-- Add validation check for required nedarim_data fields
ALTER TABLE receipts
ADD CONSTRAINT valid_nedarim_data
CHECK (
  nedarim_data IS NULL OR (
    nedarim_data ? 'result' AND
    nedarim_data ? 'mosad_id' AND
    nedarim_data ? 'zeout' AND
    nedarim_data ? 'amount'
  )
);

-- Update existing receipts with empty nedarim_data
UPDATE receipts 
SET nedarim_data = '{}'::jsonb 
WHERE nedarim_data IS NULL;