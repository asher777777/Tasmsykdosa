/*
  # Fix receipts storage setup

  1. Changes
    - Add external_url column to store PDF URLs from external storage
    - Remove storage bucket dependencies
    - Update existing records
*/

-- Add external_url column to receipts table
ALTER TABLE receipts 
ADD COLUMN IF NOT EXISTS external_url text;

-- Update existing records to use external_url
UPDATE receipts 
SET external_url = COALESCE(receipt_url, pdf_url) 
WHERE external_url IS NULL 
  AND (receipt_url IS NOT NULL OR pdf_url IS NOT NULL);

-- Drop storage-related policies since we'll use external storage
DROP POLICY IF EXISTS "Give users access to own folder" ON storage.objects;
DROP POLICY IF EXISTS "Enable upload access for authenticated users" ON storage.objects;
DROP POLICY IF EXISTS "Enable update access for authenticated users" ON storage.objects;
DROP POLICY IF EXISTS "Enable delete access for authenticated users" ON storage.objects;