/*
  # Add customer identification fields

  1. Changes
    - Add zeout (ID) column to customers table
    - Add email column to customers table
    - Add city column to customers table

  2. Notes
    - zeout is used for Israeli ID numbers
    - All fields are nullable to maintain compatibility with existing records
*/

-- Add new columns if they don't exist
ALTER TABLE customers 
ADD COLUMN IF NOT EXISTS zeout text,
ADD COLUMN IF NOT EXISTS email text,
ADD COLUMN IF NOT EXISTS city text;

-- Create index on zeout for faster lookups
CREATE INDEX IF NOT EXISTS customers_zeout_idx ON customers(zeout);

-- Create index on email for faster lookups
CREATE INDEX IF NOT EXISTS customers_email_idx ON customers(email);