/*
  # Create orders table

  1. New Tables
    - `orders`
      - `id` (uuid, primary key)
      - `created_at` (timestamp)
      - `status` (text) - pending/processing/completed/cancelled
      - `total` (decimal)
      - `payment_method` (text) - credit/bit/cash
      - `customer_name` (text)
      - `customer_phone` (text)
      - `customer_address` (text)
      - `items` (jsonb) - array of order items

  2. Security
    - Enable RLS on `orders` table
    - Add policies for read/write access
*/

CREATE TABLE IF NOT EXISTS orders (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at timestamptz DEFAULT now(),
  status text NOT NULL CHECK (status IN ('pending', 'processing', 'completed', 'cancelled')) DEFAULT 'pending',
  total decimal(10,2) NOT NULL,
  payment_method text NOT NULL CHECK (payment_method IN ('credit', 'bit', 'cash')),
  customer_name text NOT NULL,
  customer_phone text NOT NULL,
  customer_address text,
  items jsonb NOT NULL DEFAULT '[]'::jsonb
);

ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

-- Allow read access to everyone
CREATE POLICY "Orders are viewable by everyone"
  ON orders
  FOR SELECT
  USING (true);

-- Allow insert for everyone (needed for customer orders)
CREATE POLICY "Anyone can create orders"
  ON orders
  FOR INSERT
  WITH CHECK (true);

-- Allow update/delete for authenticated users only
CREATE POLICY "Authenticated users can manage orders"
  ON orders
  FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);