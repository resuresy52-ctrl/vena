/*
  # Create Profiles Table

  1. New Tables
    - `profiles`
      - `id` (uuid, primary key)
      - `admin_user_id` (uuid, foreign key to users)
      - `full_name` (text)
      - `email` (text)
      - `phone` (text)
      - `company_name` (text)
      - `website` (text)
      - `address` (text)
      - `bank_account` (text)
      - `authorized_signer` (text)
      - `id_number` (text, optional)
      - `bio` (text)
      - `income_categories` (jsonb array)
      - `expense_categories` (jsonb array)
      - `project_types` (jsonb array)
      - `event_types` (jsonb array)
      - `asset_categories` (jsonb array)
      - `sop_categories` (jsonb array)
      - `package_categories` (jsonb array)
      - `project_status_config` (jsonb array)
      - `notification_settings` (jsonb)
      - `security_settings` (jsonb)
      - `briefing_template` (text)
      - `terms_and_conditions` (text)
      - `contract_template` (text)
      - `logo_base64` (text)
      - `brand_color` (text)
      - `public_page_config` (jsonb)
      - `package_share_template` (text)
      - `booking_form_template` (text)
      - `chat_templates` (jsonb array)
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

  2. Security
    - Enable RLS on `profiles` table
    - Add policies for authenticated users
*/

CREATE TABLE IF NOT EXISTS profiles (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  admin_user_id uuid REFERENCES users(id) ON DELETE CASCADE,
  full_name text NOT NULL DEFAULT '',
  email text NOT NULL DEFAULT '',
  phone text NOT NULL DEFAULT '',
  company_name text NOT NULL DEFAULT '',
  website text DEFAULT '',
  address text DEFAULT '',
  bank_account text DEFAULT '',
  authorized_signer text DEFAULT '',
  id_number text,
  bio text DEFAULT '',
  income_categories jsonb DEFAULT '["DP Proyek", "Pelunasan Proyek", "Lainnya"]'::jsonb,
  expense_categories jsonb DEFAULT '["Operasional", "Peralatan", "Transport", "Freelancer", "Lainnya"]'::jsonb,
  project_types jsonb DEFAULT '["Pernikahan", "Lamaran", "Prewedding", "Korporat", "Ulang Tahun", "Produk", "Keluarga"]'::jsonb,
  event_types jsonb DEFAULT '["Meeting Klien", "Survey Lokasi", "Libur", "Workshop", "Lainnya"]'::jsonb,
  asset_categories jsonb DEFAULT '["Kamera", "Lensa", "Lighting", "Audio", "Komputer", "Lainnya"]'::jsonb,
  sop_categories jsonb DEFAULT '["Fotografi", "Videografi", "Editing", "Administrasi", "Umum"]'::jsonb,
  package_categories jsonb DEFAULT '["Pernikahan", "Lamaran", "Prewedding", "Korporat", "Ulang Tahun", "Produk", "Keluarga"]'::jsonb,
  project_status_config jsonb DEFAULT '[
    {"id": "1", "name": "Dikonfirmasi", "color": "#10b981", "subStatuses": [], "note": "Proyek telah dikonfirmasi dan siap dimulai"},
    {"id": "2", "name": "Briefing", "color": "#3b82f6", "subStatuses": [{"name": "Persiapan Brief", "note": "Menyiapkan materi briefing"}, {"name": "Meeting Brief", "note": "Pelaksanaan meeting briefing"}], "note": "Tahap briefing dengan klien"},
    {"id": "3", "name": "Produksi", "color": "#8b5cf6", "subStatuses": [{"name": "Persiapan Alat", "note": "Mempersiapkan peralatan"}, {"name": "Eksekusi Shooting", "note": "Pelaksanaan pemotretan"}], "note": "Tahap produksi/shooting"},
    {"id": "4", "name": "Editing", "color": "#f97316", "subStatuses": [{"name": "Seleksi Foto", "note": "Memilih foto terbaik"}, {"name": "Edit Foto", "note": "Proses editing foto"}, {"name": "Edit Video", "note": "Proses editing video"}], "note": "Tahap post-produksi"},
    {"id": "5", "name": "Printing", "color": "#06b6d4", "subStatuses": [{"name": "Persiapan File", "note": "Menyiapkan file untuk cetak"}, {"name": "Proses Cetak", "note": "Proses pencetakan"}], "note": "Tahap pencetakan produk fisik"},
    {"id": "6", "name": "Dikirim", "color": "#eab308", "subStatuses": [], "note": "Produk sedang dalam pengiriman"},
    {"id": "7", "name": "Selesai", "color": "#6366f1", "subStatuses": [], "note": "Proyek telah selesai"},
    {"id": "8", "name": "Dibatalkan", "color": "#ef4444", "subStatuses": [], "note": "Proyek dibatalkan"}
  ]'::jsonb,
  notification_settings jsonb DEFAULT '{"newProject": true, "paymentConfirmation": true, "deadlineReminder": true}'::jsonb,
  security_settings jsonb DEFAULT '{"twoFactorEnabled": false}'::jsonb,
  briefing_template text DEFAULT '',
  terms_and_conditions text,
  contract_template text,
  logo_base64 text,
  brand_color text DEFAULT '#3b82f6',
  public_page_config jsonb DEFAULT '{"template": "modern", "title": "Paket Layanan Fotografi & Videografi", "introduction": "Pilih paket yang sesuai dengan kebutuhan acara Anda. Setiap paket dirancang untuk memberikan hasil terbaik dengan harga yang kompetitif.", "galleryImages": []}'::jsonb,
  package_share_template text,
  booking_form_template text,
  chat_templates jsonb DEFAULT '[
    {"id": "greeting", "title": "Salam Pembuka", "template": "Halo {clientName}! Terima kasih telah mempercayakan {companyName} untuk proyek {projectName}. Kami akan memberikan pelayanan terbaik untuk Anda."},
    {"id": "reminder", "title": "Pengingat", "template": "Halo {clientName}, ini adalah pengingat untuk proyek {projectName}. Jangan lupa untuk mempersiapkan hal-hal yang sudah kita diskusikan sebelumnya."},
    {"id": "completion", "title": "Proyek Selesai", "template": "Halo {clientName}! Proyek {projectName} telah selesai. Terima kasih atas kepercayaannya. Semoga hasil yang kami berikan memuaskan!"}
  ]'::jsonb,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Profiles are viewable by authenticated users"
  ON profiles
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Profiles are editable by admin users"
  ON profiles
  FOR ALL
  TO authenticated
  USING (admin_user_id = auth.uid());

-- Insert default profile
INSERT INTO profiles (
  admin_user_id, full_name, email, phone, company_name, website, address, 
  bank_account, authorized_signer, bio
) 
SELECT 
  id, 'Nina Vena', 'admin@vena.pictures', '085693762240', 'Vena Pictures', 
  'https://venapictures.com', 'Jl. Contoh No. 123, Jakarta', 
  'BCA 1234567890 a.n. Nina Vena', 'Nina Vena', 
  'Vena Pictures adalah studio fotografi profesional yang mengkhususkan diri dalam dokumentasi pernikahan, prewedding, dan acara spesial lainnya.'
FROM users 
WHERE email = 'admin@vena.pictures'
ON CONFLICT DO NOTHING;