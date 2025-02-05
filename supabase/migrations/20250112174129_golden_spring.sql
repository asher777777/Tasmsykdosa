/*
  # Add receipts functionality

  1. New Tables
    - `receipts`
      - `id` (uuid, primary key)
      - `order_id` (uuid, references orders)
      - `receipt_number` (text, unique)
      - `pdf_url` (text)
      - `created_at` (timestamptz)
      - `total` (decimal)
      - `items` (jsonb)
      - `customer_details` (jsonb)

  2. Changes
    - Add receipt_id to orders table
    - Add status tracking for receipts

  3. Security
    - Enable RLS
    - Add policies for authenticated access
*/

-- Create receipts table
CREATE TABLE IF NOT EXISTS receipts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id uuid REFERENCES orders(id) ON DELETE CASCADE,
  receipt_number text UNIQUE NOT NULL,
  pdf_url text,
  created_at timestamptz DEFAULT now(),
  total decimal(10,2) NOT NULL,
  items jsonb NOT NULL,
  customer_details jsonb NOT NULL,
  CONSTRAINT valid_receipt_number CHECK (receipt_number ~ '^[0-9]{4}-[0-9]{8}$')
);

-- Add receipt tracking to orders
ALTER TABLE orders ADD COLUMN IF NOT EXISTS receipt_id uuid REFERENCES receipts(id);
ALTER TABLE orders ADD COLUMN IF NOT EXISTS status_history jsonb DEFAULT '[]'::jsonb;

-- Enable RLS
ALTER TABLE receipts ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Enable read access for all users"
  ON receipts FOR SELECT
  USING (true);

CREATE POLICY "Enable insert for authenticated users"
  ON receipts
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Enable update for authenticated users"
  ON receipts
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Create function to generate receipt number
CREATE OR REPLACE FUNCTION generate_receipt_number()
RETURNS text
LANGUAGE plpgsql
AS $$
DECLARE
  year text;
  sequence text;
BEGIN
  year := to_char(current_date, 'YYYY');
  sequence := to_char(nextval('receipt_number_seq'::regclass), 'FM00000000');
  RETURN year || '-' || sequence;
END;
$$;

-- Create sequence for receipt numbers
CREATE SEQUENCE IF NOT EXISTS receipt_number_seq
  START WITH 1
  INCREMENT BY 1
  NO MAXVALUE
  CACHE 1;