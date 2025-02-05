/*
  # Improve contacts trigger handling

  1. Changes
    - Add check to ensure at least one primary contact per customer
    - Handle case when setting primary contact to false
    - Add validation for contact data

  2. Security
    - Maintain existing RLS policies
*/

-- Drop existing trigger and function
DROP TRIGGER IF EXISTS ensure_single_primary_contact ON contacts;
DROP FUNCTION IF EXISTS handle_primary_contact();

-- Create improved function
CREATE OR REPLACE FUNCTION handle_primary_contact()
RETURNS TRIGGER AS $$
BEGIN
  -- If setting a contact as primary
  IF NEW.is_primary THEN
    -- Set all other contacts for this customer to not primary
    UPDATE contacts
    SET is_primary = false
    WHERE customer_id = NEW.customer_id
    AND id != NEW.id;
  ELSE
    -- If unsetting primary, ensure there's another primary contact
    -- or this is the only contact
    IF NOT EXISTS (
      SELECT 1 FROM contacts 
      WHERE customer_id = NEW.customer_id 
      AND id != NEW.id 
      AND is_primary = true
    ) THEN
      -- If this is the only contact, force it to be primary
      IF (
        SELECT COUNT(*) FROM contacts 
        WHERE customer_id = NEW.customer_id
      ) = 1 THEN
        NEW.is_primary := true;
      END IF;
    END IF;
  END IF;

  -- Validate contact data
  IF NEW.phone IS NULL AND NEW.email IS NULL THEN
    RAISE EXCEPTION 'Contact must have either phone or email';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create new trigger
CREATE TRIGGER ensure_single_primary_contact
  BEFORE INSERT OR UPDATE ON contacts
  FOR EACH ROW
  EXECUTE FUNCTION handle_primary_contact();

-- Add check constraint for contact methods
ALTER TABLE contacts
ADD CONSTRAINT contact_method_required
CHECK (phone IS NOT NULL OR email IS NOT NULL);

-- Create index for contact lookup by phone or email
CREATE INDEX IF NOT EXISTS idx_contacts_phone_email 
ON contacts(phone, email) 
WHERE phone IS NOT NULL OR email IS NOT NULL;