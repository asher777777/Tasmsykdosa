/*
  # Remove duplicate phone numbers

  1. Changes
    - Remove duplicate phone numbers by keeping the most recent record
  
  2. Notes
    - This migration safely handles existing duplicates
    - Keeps the most recent record for each phone number
    - The unique constraint already exists, so we only need to clean duplicates
*/

-- Remove duplicates keeping the most recent record
WITH duplicates AS (
  SELECT id,
         phone,
         ROW_NUMBER() OVER (PARTITION BY phone ORDER BY created_at DESC) as rn
  FROM customers
  WHERE phone IS NOT NULL
)
DELETE FROM customers
WHERE id IN (
  SELECT id 
  FROM duplicates 
  WHERE rn > 1
);