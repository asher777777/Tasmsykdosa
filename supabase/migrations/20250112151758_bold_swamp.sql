-- Add new columns to customers table with proper constraints
ALTER TABLE customers 
ADD COLUMN IF NOT EXISTS gender text CHECK (gender IN ('male', 'female', 'other')),
ADD COLUMN IF NOT EXISTS age_group text CHECK (age_group IN ('0-18', '19-30', '31-50', '51+', null)),
ADD COLUMN IF NOT EXISTS tags text[] DEFAULT ARRAY[]::text[],
ADD COLUMN IF NOT EXISTS is_buyer boolean DEFAULT false;