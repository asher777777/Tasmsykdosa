/*
  # Add receipt slug and update policies

  1. New Columns
    - `slug` (text, unique) for receipt URLs
  
  2. Changes
    - Add function to generate receipt slugs
    - Add trigger to auto-generate slugs
    - Update RLS policies for public access
*/

-- Add slug column
ALTER TABLE receipts
ADD COLUMN IF NOT EXISTS slug text UNIQUE;

-- Create function to generate receipt slug
CREATE OR REPLACE FUNCTION generate_receipt_slug()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.slug IS NULL THEN
    NEW.slug := encode(gen_random_bytes(8), 'hex');
  END IF;
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger for slug generation
DROP TRIGGER IF EXISTS generate_receipt_slug_trigger ON receipts;
CREATE TRIGGER generate_receipt_slug_trigger
  BEFORE INSERT ON receipts
  FOR EACH ROW
  EXECUTE FUNCTION generate_receipt_slug();

-- Update existing receipts with slugs
UPDATE receipts 
SET slug = encode(gen_random_bytes(8), 'hex')
WHERE slug IS NULL;