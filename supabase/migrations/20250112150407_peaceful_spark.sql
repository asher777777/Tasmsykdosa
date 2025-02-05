/*
  # Add Customer Fields

  1. Changes
    - Add gender field to customers table
    - Add age_group field to customers table
    - Add tags field to customers table
    - Add is_buyer field to customers table

  2. Security
    - Maintain existing RLS policies
*/

ALTER TABLE customers 
ADD COLUMN IF NOT EXISTS gender text CHECK (gender IN ('male', 'female', 'other')),
ADD COLUMN IF NOT EXISTS age_group text CHECK (age_group IN ('0-18', '19-30', '31-50', '51+')),
ADD COLUMN IF NOT EXISTS tags text[] DEFAULT ARRAY[]::text[],
ADD COLUMN IF NOT EXISTS is_buyer boolean DEFAULT false;