/*
  # Create products table

  1. New Tables
    - `products`
      - `id` (text, primary key) - The product's unique identifier (ITEMKEY)
      - `name` (text) - Hebrew name
      - `english_name` (text) - English name
      - `price` (decimal) - Product price
      - `image` (text) - Image URL
      - `weight` (decimal) - Product weight
      - `barcode` (text) - Product barcode
      - `material` (text) - Product material
      - `width` (decimal) - Product width
      - `length` (decimal) - Product length
      - `depth` (decimal) - Product depth
      - `category` (text) - Product category
      - `in_stock` (integer) - Stock quantity
      - `color` (text) - Product color
      - `language` (text) - Product language
      - `item_size` (text) - Product size
      - `periodical_zation` (text) - Periodical information
      - `created_at` (timestamptz) - Creation timestamp
      - `updated_at` (timestamptz) - Last update timestamp

  2. Security
    - Enable RLS on `products` table
    - Add policies for authenticated users to manage products
*/

CREATE TABLE IF NOT EXISTS products (
  id text PRIMARY KEY,
  name text NOT NULL,
  english_name text,
  price decimal(10,2) NOT NULL,
  image text,
  weight decimal(10,3),
  barcode text,
  material text,
  width decimal(10,2),
  length decimal(10,2),
  depth decimal(10,2),
  category text,
  in_stock integer DEFAULT 0,
  color text,
  language text,
  item_size text,
  periodical_zation text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- Allow read access to everyone
CREATE POLICY "Products are viewable by everyone"
  ON products
  FOR SELECT
  USING (true);

-- Allow authenticated users to insert/update/delete products
CREATE POLICY "Authenticated users can manage products"
  ON products
  FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);