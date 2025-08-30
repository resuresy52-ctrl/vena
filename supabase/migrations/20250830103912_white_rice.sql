/*
  # Create Projects Table

  1. New Tables
    - `projects`
      - `id` (uuid, primary key)
      - `project_name` (text)
      - `client_name` (text)
      - `client_id` (uuid, foreign key)
      - `project_type` (text)
      - `package_name` (text)
      - `package_id` (uuid, foreign key)
      - `add_ons` (jsonb array)
      - `date` (date)
      - `deadline_date` (date, optional)
      - `location` (text)
      - `progress` (integer)
      - `status` (text)
      - `active_sub_statuses` (jsonb array)
      - `total_cost` (numeric)
      - `amount_paid` (numeric)
      - `payment_status` (text)
      - `team` (jsonb array)
      - `notes` (text, optional)
      - `accommodation` (text, optional)
      - `drive_link` (text, optional)
      - `client_drive_link` (text, optional)
      - `final_drive_link` (text, optional)
      - `start_time` (text, optional)
      - `end_time` (text, optional)
      - `image` (text, optional)
      - `revisions` (jsonb array)
      - `promo_code_id` (uuid, optional)
      - `discount_amount` (numeric, optional)
      - `shipping_details` (text, optional)
      - `dp_proof_url` (text, optional)
      - `printing_details` (jsonb array)
      - `printing_cost` (numeric, optional)
      - `transport_cost` (numeric, optional)
      - `booking_status` (text, optional)
      - `rejection_reason` (text, optional)
      - `chat_history` (jsonb array)
      - `confirmed_sub_statuses` (jsonb array)
      - `client_sub_status_notes` (jsonb)
      - `completed_digital_items` (jsonb array)
      - `invoice_signature` (text, optional)
      - `custom_sub_statuses` (jsonb array)
      - Various client confirmation flags
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

  2. Security
    - Enable RLS on `projects` table
    - Add policies for authenticated users
*/

CREATE TABLE IF NOT EXISTS projects (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_name text NOT NULL,
  client_name text NOT NULL,
  client_id uuid REFERENCES clients(id) ON DELETE CASCADE,
  project_type text NOT NULL,
  package_name text NOT NULL,
  package_id uuid REFERENCES packages(id),
  add_ons jsonb DEFAULT '[]'::jsonb,
  date date NOT NULL,
  deadline_date date,
  location text NOT NULL DEFAULT '',
  progress integer DEFAULT 0 CHECK (progress >= 0 AND progress <= 100),
  status text NOT NULL DEFAULT 'Dikonfirmasi',
  active_sub_statuses jsonb DEFAULT '[]'::jsonb,
  total_cost numeric NOT NULL DEFAULT 0,
  amount_paid numeric DEFAULT 0,
  payment_status text NOT NULL DEFAULT 'Belum Bayar' CHECK (payment_status IN ('Lunas', 'DP Terbayar', 'Belum Bayar')),
  team jsonb DEFAULT '[]'::jsonb,
  notes text,
  accommodation text,
  drive_link text,
  client_drive_link text,
  final_drive_link text,
  start_time text,
  end_time text,
  image text,
  revisions jsonb DEFAULT '[]'::jsonb,
  promo_code_id uuid,
  discount_amount numeric,
  shipping_details text,
  dp_proof_url text,
  printing_details jsonb DEFAULT '[]'::jsonb,
  printing_cost numeric,
  transport_cost numeric,
  booking_status text CHECK (booking_status IN ('Baru', 'Terkonfirmasi', 'Ditolak')),
  rejection_reason text,
  chat_history jsonb DEFAULT '[]'::jsonb,
  confirmed_sub_statuses jsonb DEFAULT '[]'::jsonb,
  client_sub_status_notes jsonb DEFAULT '{}'::jsonb,
  completed_digital_items jsonb DEFAULT '[]'::jsonb,
  invoice_signature text,
  custom_sub_statuses jsonb DEFAULT '[]'::jsonb,
  is_editing_confirmed_by_client boolean DEFAULT false,
  is_printing_confirmed_by_client boolean DEFAULT false,
  is_delivery_confirmed_by_client boolean DEFAULT false,
  sub_status_confirmation_sent_at jsonb DEFAULT '{}'::jsonb,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE projects ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Projects are viewable by authenticated users"
  ON projects
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Projects are manageable by authenticated users"
  ON projects
  FOR ALL
  TO authenticated
  USING (true);