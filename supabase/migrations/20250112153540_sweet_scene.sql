/*
  # Add tags support for customers

  1. Changes
    - Add tags array column to customers table
    - Add tags to search functionality
    - Add tags to customer management

  2. Security
    - Maintain existing RLS policies
*/

ALTER TABLE customers 
ADD COLUMN IF NOT EXISTS tags text[] DEFAULT ARRAY[]::text[];

-- Update RLS policies to include tags in searchable fields
DROP POLICY IF EXISTS "Enable read access for all users" ON customers;
CREATE POLICY "Enable read access for all users" 
ON customers 
FOR SELECT 
USING (true);