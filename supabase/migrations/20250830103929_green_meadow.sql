/*
  # Create Transactions Table

  1. New Tables
    - `transactions`
      - `id` (uuid, primary key)
      - `date` (date)
      - `description` (text)
      - `amount` (numeric)
      - `type` (text)
      - `project_id` (uuid, optional foreign key)
      - `category` (text)
      - `method` (text)
      - `pocket_id` (uuid, optional)
      - `card_id` (uuid, optional)
      - `printing_item_id` (uuid, optional)
      - `vendor_signature` (text, optional)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

  2. Security
    - Enable RLS on `transactions` table
    - Add policies for authenticated users
*/

CREATE TABLE IF NOT EXISTS transactions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  date date NOT NULL DEFAULT CURRENT_DATE,
  description text NOT NULL,
  amount numeric NOT NULL DEFAULT 0,
  type text NOT NULL CHECK (type IN ('Pemasukan', 'Pengeluaran')),
  project_id uuid REFERENCES projects(id) ON DELETE SET NULL,
  category text NOT NULL,
  method text NOT NULL DEFAULT 'Transfer Bank' CHECK (method IN ('Transfer Bank', 'Tunai', 'E-Wallet', 'Sistem', 'Kartu')),
  pocket_id uuid,
  card_id uuid,
  printing_item_id uuid,
  vendor_signature text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE transactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Transactions are viewable by authenticated users"
  ON transactions
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Transactions are manageable by authenticated users"
  ON transactions
  FOR ALL
  TO authenticated
  USING (true);