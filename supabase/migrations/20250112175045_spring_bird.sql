/*
  # Fix receipts table setup

  1. Changes
    - Add receipt_url column to receipts table
    - Remove storage policies since bucket needs manual creation
*/

-- Add receipt_url column to receipts table if it doesn't exist
ALTER TABLE receipts 
ADD COLUMN IF NOT EXISTS receipt_url text;

-- Update receipt_url from pdf_url for existing records
UPDATE receipts 
SET receipt_url = pdf_url 
WHERE receipt_url IS NULL AND pdf_url IS NOT NULL;