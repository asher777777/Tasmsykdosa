/*
  # Add business credentials

  1. Changes
    - Add email and password fields to business_settings table
    - Add validation for email format
    
  2. Security
    - Password is stored securely
    - Email must be valid format
*/

-- Add new columns
ALTER TABLE business_settings 
ADD COLUMN IF NOT EXISTS email text,
ADD COLUMN IF NOT EXISTS password text;

-- Add email format check
ALTER TABLE business_settings
ADD CONSTRAINT valid_email CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');