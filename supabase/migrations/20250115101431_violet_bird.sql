/*
  # Fix cash payment functionality

  1. New Columns
    - Add `payment_status` to orders table
    - Add `payment_details` to orders table
    - Add `payment_error` to orders table
  
  2. Changes
    - Add constraints to ensure valid payment data
    - Add default values for new columns
*/

-- Add new columns to orders table
ALTER TABLE orders
ADD COLUMN IF NOT EXISTS payment_status text CHECK (payment_status IN ('pending', 'completed', 'failed')) DEFAULT 'pending',
ADD COLUMN IF NOT EXISTS payment_details jsonb DEFAULT '{}'::jsonb,
ADD COLUMN IF NOT EXISTS payment_error text;

-- Create index for payment status
CREATE INDEX IF NOT EXISTS idx_orders_payment_status ON orders(payment_status);

-- Update existing orders
UPDATE orders 
SET payment_status = 'completed' 
WHERE payment_status IS NULL AND status = 'completed';