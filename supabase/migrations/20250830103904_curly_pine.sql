/*
  # Create Team Members Table

  1. New Tables
    - `team_members`
      - `id` (uuid, primary key)
      - `name` (text)
      - `role` (text)
      - `email` (text)
      - `phone` (text)
      - `standard_fee` (numeric)
      - `no_rek` (text, optional)
      - `reward_balance` (numeric)
      - `rating` (numeric)
      - `performance_notes` (jsonb array)
      - `portal_access_id` (uuid, unique)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

  2. Security
    - Enable RLS on `team_members` table
    - Add policies for authenticated users
*/

CREATE TABLE IF NOT EXISTS team_members (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  role text NOT NULL,
  email text NOT NULL,
  phone text NOT NULL,
  standard_fee numeric NOT NULL DEFAULT 0,
  no_rek text,
  reward_balance numeric DEFAULT 0,
  rating numeric DEFAULT 5.0 CHECK (rating >= 1 AND rating <= 5),
  performance_notes jsonb DEFAULT '[]'::jsonb,
  portal_access_id uuid UNIQUE DEFAULT gen_random_uuid(),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE team_members ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Team members are viewable by authenticated users"
  ON team_members
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Team members are manageable by authenticated users"
  ON team_members
  FOR ALL
  TO authenticated
  USING (true);

-- Insert sample team members
INSERT INTO team_members (name, role, email, phone, standard_fee, no_rek, rating) VALUES
('Andi Photographer', 'Fotografer', 'andi@example.com', '081234567890', 500000, 'BCA 9876543210', 4.8),
('Budi Videographer', 'Videografer', 'budi@example.com', '081234567891', 600000, 'Mandiri 1122334455', 4.9),
('Citra Editor', 'Editor', 'citra@example.com', '081234567892', 300000, 'BNI 5566778899', 4.7)
ON CONFLICT DO NOTHING;