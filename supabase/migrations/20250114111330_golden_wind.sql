/*
  # Add customer contacts relation

  1. Changes
    - Add customer_id foreign key to contacts table
    - Add indexes for better performance
    - Add partial index for primary contacts

  2. Security
    - Add trigger for handling primary contact changes
*/

-- Add customer_id foreign key to contacts table if it doesn't exist
DO $$ 
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_name = 'contacts' 
    AND column_name = 'customer_id'
  ) THEN
    ALTER TABLE contacts
    ADD COLUMN customer_id uuid REFERENCES customers(id) ON DELETE CASCADE;
  END IF;
END $$;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_contacts_customer_id ON contacts(customer_id);
CREATE INDEX IF NOT EXISTS idx_contacts_is_primary ON contacts(is_primary);

-- Create partial index to ensure only one primary contact per customer
CREATE UNIQUE INDEX IF NOT EXISTS unique_primary_contact_per_customer
ON contacts (customer_id)
WHERE is_primary = true;

-- Add trigger to handle primary contact changes
CREATE OR REPLACE FUNCTION handle_primary_contact()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.is_primary THEN
    -- Set all other contacts for this customer to not primary
    UPDATE contacts
    SET is_primary = false
    WHERE customer_id = NEW.customer_id
    AND id != NEW.id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop trigger if exists and recreate
DROP TRIGGER IF EXISTS ensure_single_primary_contact ON contacts;
CREATE TRIGGER ensure_single_primary_contact
  BEFORE INSERT OR UPDATE ON contacts
  FOR EACH ROW
  EXECUTE FUNCTION handle_primary_contact();