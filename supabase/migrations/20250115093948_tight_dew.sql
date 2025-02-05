-- Create logos bucket
INSERT INTO storage.buckets (id, name)
VALUES ('logos', 'logos')
ON CONFLICT (id) DO NOTHING;

-- Set up storage policies for logos bucket
CREATE POLICY "Logos are publicly accessible"
ON storage.objects FOR SELECT
USING (bucket_id = 'logos');

CREATE POLICY "Users can upload logos"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'logos' AND
  auth.role() = 'authenticated'
);

CREATE POLICY "Users can update logos"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'logos' AND
  auth.role() = 'authenticated'
);

CREATE POLICY "Users can delete logos"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'logos' AND
  auth.role() = 'authenticated'
);