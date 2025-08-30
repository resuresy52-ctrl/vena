/*
  # Create Packages and Add-ons Tables

  1. New Tables
    - `packages`
      - `id` (uuid, primary key)
      - `name` (text)
      - `price` (numeric)
      - `category` (text)
      - `physical_items` (jsonb array)
      - `digital_items` (jsonb array)
      - `processing_time` (text)
      - `photographers` (text, optional)
      - `videographers` (text, optional)
      - `cover_image` (text, optional)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)
    
    - `add_ons`
      - `id` (uuid, primary key)
      - `name` (text)
      - `price` (numeric)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

  2. Security
    - Enable RLS on both tables
    - Add policies for authenticated users and public read access
*/

CREATE TABLE IF NOT EXISTS packages (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  price numeric NOT NULL DEFAULT 0,
  category text NOT NULL DEFAULT '',
  physical_items jsonb DEFAULT '[]'::jsonb,
  digital_items jsonb DEFAULT '[]'::jsonb,
  processing_time text DEFAULT '',
  photographers text,
  videographers text,
  cover_image text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS add_ons (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  price numeric NOT NULL DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE packages ENABLE ROW LEVEL SECURITY;
ALTER TABLE add_ons ENABLE ROW LEVEL SECURITY;

-- Public read access for packages and add-ons (for public pages)
CREATE POLICY "Packages are publicly readable"
  ON packages
  FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Add-ons are publicly readable"
  ON add_ons
  FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Packages are manageable by authenticated users"
  ON packages
  FOR ALL
  TO authenticated
  USING (true);

CREATE POLICY "Add-ons are manageable by authenticated users"
  ON add_ons
  FOR ALL
  TO authenticated
  USING (true);

-- Insert sample packages
INSERT INTO packages (name, price, category, physical_items, digital_items, processing_time, photographers, videographers) VALUES
('Basic Wedding', 5000000, 'Pernikahan', '[{"name": "Album 20x30 (20 halaman)", "price": 500000}]'::jsonb, '["300+ Foto High Resolution", "Video Highlight 3-5 menit"]'::jsonb, '30 hari kerja', '1 Fotografer', '1 Videografer'),
('Premium Wedding', 8000000, 'Pernikahan', '[{"name": "Album 25x35 (30 halaman)", "price": 800000}, {"name": "Flashdisk Custom", "price": 100000}]'::jsonb, '["500+ Foto High Resolution", "Video Cinematic 5-8 menit", "Same Day Edit"]'::jsonb, '45 hari kerja', '2 Fotografer', '1 Videografer'),
('Prewedding Package', 3000000, 'Prewedding', '[{"name": "Cetak Foto 4R (50 lembar)", "price": 200000}]'::jsonb, '["200+ Foto High Resolution", "Video Teaser 1-2 menit"]'::jsonb, '21 hari kerja', '1 Fotografer', '1 Videografer')
ON CONFLICT DO NOTHING;

-- Insert sample add-ons
INSERT INTO add_ons (name, price) VALUES
('Drone Photography', 500000),
('Make Up Artist', 800000),
('Extra Photographer', 1000000),
('Live Streaming', 1500000),
('Photo Booth', 750000)
ON CONFLICT DO NOTHING;