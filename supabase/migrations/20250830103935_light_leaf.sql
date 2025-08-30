/*
  # Create Cards and Financial Pockets Tables

  1. New Tables
    - `cards`
      - `id` (uuid, primary key)
      - `card_holder_name` (text)
      - `bank_name` (text)
      - `card_type` (text)
      - `last_four_digits` (text)
      - `expiry_date` (text, optional)
      - `balance` (numeric)
      - `color_gradient` (text)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)
    
    - `financial_pockets`
      - `id` (uuid, primary key)
      - `name` (text)
      - `description` (text)
      - `icon` (text)
      - `type` (text)
      - `amount` (numeric)
      - `goal_amount` (numeric, optional)
      - `lock_end_date` (date, optional)
      - `members` (jsonb array, optional)
      - `source_card_id` (uuid, optional)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

  2. Security
    - Enable RLS on both tables
    - Add policies for authenticated users
*/

CREATE TABLE IF NOT EXISTS cards (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  card_holder_name text NOT NULL,
  bank_name text NOT NULL,
  card_type text NOT NULL CHECK (card_type IN ('Prabayar', 'Kredit', 'Debit', 'Tunai')),
  last_four_digits text NOT NULL,
  expiry_date text,
  balance numeric DEFAULT 0,
  color_gradient text NOT NULL DEFAULT 'from-blue-500 to-sky-400',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS financial_pockets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  description text NOT NULL DEFAULT '',
  icon text NOT NULL DEFAULT 'piggy-bank' CHECK (icon IN ('piggy-bank', 'lock', 'users', 'clipboard-list', 'star')),
  type text NOT NULL CHECK (type IN ('Nabung & Bayar', 'Terkunci', 'Bersama', 'Anggaran Pengeluaran', 'Tabungan Hadiah Freelancer')),
  amount numeric DEFAULT 0,
  goal_amount numeric,
  lock_end_date date,
  members jsonb DEFAULT '[]'::jsonb,
  source_card_id uuid REFERENCES cards(id) ON DELETE SET NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE cards ENABLE ROW LEVEL SECURITY;
ALTER TABLE financial_pockets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Cards are viewable by authenticated users"
  ON cards
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Cards are manageable by authenticated users"
  ON cards
  FOR ALL
  TO authenticated
  USING (true);

CREATE POLICY "Financial pockets are viewable by authenticated users"
  ON financial_pockets
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Financial pockets are manageable by authenticated users"
  ON financial_pockets
  FOR ALL
  TO authenticated
  USING (true);

-- Insert default cards
INSERT INTO cards (id, card_holder_name, bank_name, card_type, last_four_digits, balance, color_gradient) VALUES
('CARD_CASH', 'Nina Vena', 'Tunai', 'Tunai', 'CASH', 2500000, 'from-green-500 to-emerald-400'),
('CARD_BCA', 'Nina Vena', 'BCA', 'Debit', '7890', 15000000, 'from-blue-500 to-sky-400'),
('CARD_MANDIRI', 'Nina Vena', 'Mandiri', 'Kredit', '1234', 8500000, 'from-yellow-500 to-orange-400')
ON CONFLICT (id) DO NOTHING;