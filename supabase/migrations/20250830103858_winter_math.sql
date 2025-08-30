/*
  # Create Leads Table

  1. New Tables
    - `leads`
      - `id` (uuid, primary key)
      - `name` (text)
      - `contact_channel` (text)
      - `location` (text)
      - `status` (text)
      - `date` (date)
      - `notes` (text, optional)
      - `whatsapp` (text, optional)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

  2. Security
    - Enable RLS on `leads` table
    - Add policies for authenticated users and public insert
*/

CREATE TABLE IF NOT EXISTS leads (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  contact_channel text NOT NULL DEFAULT 'Lainnya' CHECK (contact_channel IN ('WhatsApp', 'Instagram', 'Website', 'Telepon', 'Referensi', 'Form Saran', 'Lainnya')),
  location text NOT NULL DEFAULT '',
  status text NOT NULL DEFAULT 'Sedang Diskusi' CHECK (status IN ('Sedang Diskusi', 'Menunggu Follow Up', 'Dikonversi', 'Ditolak')),
  date date NOT NULL DEFAULT CURRENT_DATE,
  notes text,
  whatsapp text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE leads ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Leads are viewable by authenticated users"
  ON leads
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Leads are manageable by authenticated users"
  ON leads
  FOR ALL
  TO authenticated
  USING (true);

CREATE POLICY "Leads can be inserted by anyone"
  ON leads
  FOR INSERT
  TO anon, authenticated
  USING (true);