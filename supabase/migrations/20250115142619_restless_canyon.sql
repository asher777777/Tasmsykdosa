/*
  # Create posts table and relationships

  1. New Tables
    - `posts`
      - `id` (uuid, primary key)
      - `title` (text, required)
      - `content` (text, required)
      - `author_id` (uuid, references users)
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)
      - `published_at` (timestamptz)
      - `status` (text, enum: draft/published)
      - `slug` (text, unique)
      - `meta_description` (text)
      - `meta_keywords` (text[])
      - `featured_image` (text)
      - `category` (text)
      - `tags` (text[])
      - `views` (integer)
      - `likes` (integer)
      - `deleted_at` (timestamptz, for soft deletes)

  2. Security
    - Enable RLS on posts table
    - Add policies for public read access
    - Add policies for authenticated write access
    - Add policies for soft deletes
*/

-- Create posts table
CREATE TABLE IF NOT EXISTS posts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  content text NOT NULL,
  author_id uuid REFERENCES auth.users(id) ON DELETE SET NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now(),
  published_at timestamptz,
  status text NOT NULL CHECK (status IN ('draft', 'published')) DEFAULT 'draft',
  slug text UNIQUE,
  meta_description text,
  meta_keywords text[],
  featured_image text,
  category text,
  tags text[] DEFAULT ARRAY[]::text[],
  views integer DEFAULT 0,
  likes integer DEFAULT 0,
  deleted_at timestamptz,
  CONSTRAINT valid_slug CHECK (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$')
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_posts_author ON posts(author_id);
CREATE INDEX IF NOT EXISTS idx_posts_status ON posts(status);
CREATE INDEX IF NOT EXISTS idx_posts_published_at ON posts(published_at);
CREATE INDEX IF NOT EXISTS idx_posts_category ON posts(category);
CREATE INDEX IF NOT EXISTS idx_posts_deleted_at ON posts(deleted_at);

-- Enable RLS
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Public can view published posts"
  ON posts
  FOR SELECT
  USING (
    status = 'published' 
    AND published_at <= now() 
    AND deleted_at IS NULL
  );

CREATE POLICY "Authors can manage their own posts"
  ON posts
  FOR ALL
  USING (
    auth.uid() = author_id 
    AND deleted_at IS NULL
  )
  WITH CHECK (
    auth.uid() = author_id 
    AND deleted_at IS NULL
  );

CREATE POLICY "Admins can manage all posts"
  ON posts
  FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
      AND role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM user_roles
      WHERE user_id = auth.uid()
      AND role = 'admin'
    )
  );

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger for updated_at
CREATE TRIGGER update_posts_updated_at
  BEFORE UPDATE ON posts
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Create function to generate slug
CREATE OR REPLACE FUNCTION generate_post_slug()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.slug IS NULL THEN
    NEW.slug := lower(regexp_replace(NEW.title, '[^a-zA-Z0-9]+', '-', 'g'));
  END IF;
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Create trigger for slug generation
CREATE TRIGGER generate_post_slug_trigger
  BEFORE INSERT ON posts
  FOR EACH ROW
  EXECUTE FUNCTION generate_post_slug();

-- Grant permissions
GRANT SELECT ON posts TO anon;
GRANT ALL ON posts TO authenticated;