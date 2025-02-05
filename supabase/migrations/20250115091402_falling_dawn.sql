/*
  # Add transaction history to customers table

  1. Changes
    - Add transaction_history JSONB column to customers table
    - Set default empty JSON object
    - Update existing records with default value

  2. Security
    - No changes to RLS policies needed
*/

-- Add transaction_history column if it doesn't exist
ALTER TABLE customers 
ADD COLUMN IF NOT EXISTS transaction_history JSONB DEFAULT '{}'::jsonb;

-- Update any existing NULL values to empty object
UPDATE customers 
SET transaction_history = '{}'::jsonb 
WHERE transaction_history IS NULL;