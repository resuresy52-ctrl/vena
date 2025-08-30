/*
  # Create Clients Table

  1. New Tables
    - `clients`
      - `id` (uuid, primary key)
      - `name` (text)
      - `email` (text)
      - `phone` (text)
      - `whatsapp` (text, optional)
      - `instagram` (text, optional)
      - `client_type` (text)
      - `since` (date)
      - `status` (text)
      - `last_contact` (timestamp)
      - `portal_access_id` (uuid, unique)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

  2. Security
    - Enable RLS on `clients` table
    - Add policies for authenticated users
*/

CREATE TABLE IF NOT EXISTS clients (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  email text NOT NULL,
  phone text NOT NULL,
  whatsapp text,
  instagram text,
  client_type text NOT NULL DEFAULT 'Langsung' CHECK (client_type IN ('Langsung', 'Vendor')),
  since date NOT NULL DEFAULT CURRENT_DATE,
  status text NOT NULL DEFAULT 'Aktif' CHECK (status IN ('Prospek', 'Aktif', 'Tidak Aktif', 'Hilang')),
  last_contact timestamptz DEFAULT now(),
  portal_access_id uuid UNIQUE DEFAULT gen_random_uuid(),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE clients ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Clients are viewable by authenticated users"
  ON clients
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Clients are manageable by authenticated users"
  ON clients
  FOR ALL
  TO authenticated
  USING (true);