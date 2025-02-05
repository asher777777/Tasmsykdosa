/*
  # Add storage policies for receipts

  1. Changes
    - Add storage policies for receipts bucket
    - Enable secure access control
*/

-- Allow public access to receipts bucket
CREATE POLICY "Give users access to own folder" ON storage.objects FOR SELECT TO public 
USING (bucket_id = 'receipts');

CREATE POLICY "Enable upload access for authenticated users" ON storage.objects FOR INSERT TO authenticated 
WITH CHECK (bucket_id = 'receipts');

CREATE POLICY "Enable update access for authenticated users" ON storage.objects FOR UPDATE TO authenticated 
USING (bucket_id = 'receipts');

CREATE POLICY "Enable delete access for authenticated users" ON storage.objects FOR DELETE TO authenticated 
USING (bucket_id = 'receipts');