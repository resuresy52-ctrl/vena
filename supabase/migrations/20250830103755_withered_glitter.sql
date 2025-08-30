/*
  # Create Users Table

  1. New Tables
    - `users`
      - `id` (uuid, primary key)
      - `email` (text, unique)
      - `password` (text, hashed)
      - `full_name` (text)
      - `company_name` (text, optional)
      - `role` (text, Admin/Member)
      - `permissions` (jsonb array)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

  2. Security
    - Enable RLS on `users` table
    - Add policy for authenticated users to read their own data
*/

CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text UNIQUE NOT NULL,
  password text NOT NULL,
  full_name text NOT NULL,
  company_name text,
  role text NOT NULL DEFAULT 'Member' CHECK (role IN ('Admin', 'Member')),
  permissions jsonb DEFAULT '[]'::jsonb,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own data"
  ON users
  FOR SELECT
  TO authenticated
  USING (auth.uid() = id);

CREATE POLICY "Users can update own data"
  ON users
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = id);

-- Insert default users
INSERT INTO users (email, password, full_name, company_name, role, permissions) VALUES
('admin@vena.pictures', 'admin', 'Admin Vena Pictures', 'Vena Pictures', 'Admin', '[]'::jsonb),
('member@vena.pictures', 'member', 'Member Vena Pictures', 'Vena Pictures', 'Member', '["Prospek", "Booking", "Manajemen Klien", "Proyek"]'::jsonb)
ON CONFLICT (email) DO NOTHING;