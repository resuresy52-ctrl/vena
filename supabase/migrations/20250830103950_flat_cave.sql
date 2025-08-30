/*
  # Create Remaining Tables

  1. New Tables
    - `team_project_payments`
    - `team_payment_records`
    - `reward_ledger_entries`
    - `assets`
    - `contracts`
    - `client_feedback`
    - `notifications`
    - `social_media_posts`
    - `promo_codes`
    - `sops`

  2. Security
    - Enable RLS on all tables
    - Add appropriate policies
*/

CREATE TABLE IF NOT EXISTS team_project_payments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id uuid REFERENCES projects(id) ON DELETE CASCADE,
  team_member_name text NOT NULL,
  team_member_id uuid REFERENCES team_members(id) ON DELETE CASCADE,
  date date NOT NULL DEFAULT CURRENT_DATE,
  status text NOT NULL DEFAULT 'Unpaid' CHECK (status IN ('Paid', 'Unpaid')),
  fee numeric NOT NULL DEFAULT 0,
  reward numeric DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS team_payment_records (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  record_number text NOT NULL UNIQUE,
  team_member_id uuid REFERENCES team_members(id) ON DELETE CASCADE,
  date date NOT NULL DEFAULT CURRENT_DATE,
  project_payment_ids jsonb DEFAULT '[]'::jsonb,
  total_amount numeric NOT NULL DEFAULT 0,
  vendor_signature text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS reward_ledger_entries (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  team_member_id uuid REFERENCES team_members(id) ON DELETE CASCADE,
  date date NOT NULL DEFAULT CURRENT_DATE,
  description text NOT NULL,
  amount numeric NOT NULL DEFAULT 0,
  project_id uuid REFERENCES projects(id) ON DELETE SET NULL,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS assets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  category text NOT NULL,
  purchase_date date NOT NULL DEFAULT CURRENT_DATE,
  purchase_price numeric NOT NULL DEFAULT 0,
  serial_number text,
  status text NOT NULL DEFAULT 'Tersedia' CHECK (status IN ('Tersedia', 'Digunakan', 'Perbaikan')),
  notes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS contracts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  contract_number text NOT NULL UNIQUE,
  client_id uuid REFERENCES clients(id) ON DELETE CASCADE,
  project_id uuid REFERENCES projects(id) ON DELETE CASCADE,
  signing_date date NOT NULL DEFAULT CURRENT_DATE,
  signing_location text NOT NULL DEFAULT '',
  client_name1 text NOT NULL,
  client_address1 text NOT NULL DEFAULT '',
  client_phone1 text NOT NULL DEFAULT '',
  client_name2 text,
  client_address2 text,
  client_phone2 text,
  shooting_duration text NOT NULL DEFAULT '',
  guaranteed_photos text NOT NULL DEFAULT '',
  album_details text NOT NULL DEFAULT '',
  digital_files_format text DEFAULT 'JPG High-Resolution',
  other_items text NOT NULL DEFAULT '',
  personnel_count text NOT NULL DEFAULT '',
  delivery_timeframe text DEFAULT '30 hari kerja',
  dp_date date,
  final_payment_date date,
  cancellation_policy text NOT NULL DEFAULT '',
  jurisdiction text NOT NULL DEFAULT '',
  vendor_signature text,
  client_signature text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS client_feedback (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  client_name text NOT NULL,
  satisfaction text NOT NULL CHECK (satisfaction IN ('Sangat Puas', 'Puas', 'Biasa Saja', 'Tidak Puas')),
  rating integer NOT NULL CHECK (rating >= 1 AND rating <= 5),
  feedback text NOT NULL,
  date date NOT NULL DEFAULT CURRENT_DATE,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  message text NOT NULL,
  timestamp timestamptz DEFAULT now(),
  is_read boolean DEFAULT false,
  icon text NOT NULL CHECK (icon IN ('lead', 'deadline', 'revision', 'feedback', 'payment', 'completed', 'comment')),
  link_view text,
  link_action jsonb,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS social_media_posts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  project_id uuid REFERENCES projects(id) ON DELETE CASCADE,
  client_name text NOT NULL,
  post_type text NOT NULL CHECK (post_type IN ('Instagram Feed', 'Instagram Story', 'Instagram Reels', 'TikTok Video', 'Artikel Blog')),
  platform text NOT NULL CHECK (platform IN ('Instagram', 'TikTok', 'Website')),
  scheduled_date date NOT NULL DEFAULT CURRENT_DATE,
  caption text NOT NULL DEFAULT '',
  media_url text,
  status text NOT NULL DEFAULT 'Draf' CHECK (status IN ('Draf', 'Terjadwal', 'Diposting', 'Dibatalkan')),
  notes text,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS promo_codes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text NOT NULL UNIQUE,
  discount_type text NOT NULL CHECK (discount_type IN ('percentage', 'fixed')),
  discount_value numeric NOT NULL DEFAULT 0,
  is_active boolean DEFAULT true,
  usage_count integer DEFAULT 0,
  max_usage integer,
  expiry_date date,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS sops (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  category text NOT NULL,
  content text NOT NULL,
  last_updated timestamptz DEFAULT now(),
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

-- Enable RLS on all tables
ALTER TABLE team_project_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE team_payment_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE reward_ledger_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE assets ENABLE ROW LEVEL SECURITY;
ALTER TABLE contracts ENABLE ROW LEVEL SECURITY;
ALTER TABLE client_feedback ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE social_media_posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE promo_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE sops ENABLE ROW LEVEL SECURITY;

-- Create policies for authenticated users
CREATE POLICY "Team project payments are viewable by authenticated users" ON team_project_payments FOR SELECT TO authenticated USING (true);
CREATE POLICY "Team project payments are manageable by authenticated users" ON team_project_payments FOR ALL TO authenticated USING (true);

CREATE POLICY "Team payment records are viewable by authenticated users" ON team_payment_records FOR SELECT TO authenticated USING (true);
CREATE POLICY "Team payment records are manageable by authenticated users" ON team_payment_records FOR ALL TO authenticated USING (true);

CREATE POLICY "Reward ledger entries are viewable by authenticated users" ON reward_ledger_entries FOR SELECT TO authenticated USING (true);
CREATE POLICY "Reward ledger entries are manageable by authenticated users" ON reward_ledger_entries FOR ALL TO authenticated USING (true);

CREATE POLICY "Assets are viewable by authenticated users" ON assets FOR SELECT TO authenticated USING (true);
CREATE POLICY "Assets are manageable by authenticated users" ON assets FOR ALL TO authenticated USING (true);

CREATE POLICY "Contracts are viewable by authenticated users" ON contracts FOR SELECT TO authenticated USING (true);
CREATE POLICY "Contracts are manageable by authenticated users" ON contracts FOR ALL TO authenticated USING (true);

CREATE POLICY "Client feedback is viewable by authenticated users" ON client_feedback FOR SELECT TO authenticated USING (true);
CREATE POLICY "Client feedback is manageable by authenticated users" ON client_feedback FOR ALL TO authenticated USING (true);
CREATE POLICY "Client feedback can be inserted by anyone" ON client_feedback FOR INSERT TO anon, authenticated USING (true);

CREATE POLICY "Notifications are viewable by authenticated users" ON notifications FOR SELECT TO authenticated USING (true);
CREATE POLICY "Notifications are manageable by authenticated users" ON notifications FOR ALL TO authenticated USING (true);

CREATE POLICY "Social media posts are viewable by authenticated users" ON social_media_posts FOR SELECT TO authenticated USING (true);
CREATE POLICY "Social media posts are manageable by authenticated users" ON social_media_posts FOR ALL TO authenticated USING (true);

CREATE POLICY "Promo codes are viewable by authenticated users" ON promo_codes FOR SELECT TO authenticated USING (true);
CREATE POLICY "Promo codes are manageable by authenticated users" ON promo_codes FOR ALL TO authenticated USING (true);
CREATE POLICY "Promo codes are publicly readable" ON promo_codes FOR SELECT TO anon, authenticated USING (true);

CREATE POLICY "SOPs are viewable by authenticated users" ON sops FOR SELECT TO authenticated USING (true);
CREATE POLICY "SOPs are manageable by authenticated users" ON sops FOR ALL TO authenticated USING (true);