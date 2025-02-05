/*
  # Fix order status update policies

  1. Changes
    - Drop existing update policy
    - Create new policy for status updates
    - Ensure proper access control while maintaining data integrity

  2. Security
    - Allow status updates for all users
    - Validate status values
*/

-- Drop existing update policy
DROP POLICY IF EXISTS "Enable update for all users" ON orders;

-- Create new update policy
CREATE POLICY "Enable update for all users"
  ON orders
  FOR UPDATE
  USING (true)
  WITH CHECK (
    status IN ('pending', 'processing', 'completed', 'cancelled') AND
    status_history IS NOT NULL
  );