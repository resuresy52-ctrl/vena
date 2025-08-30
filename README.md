<div align="center">
<img width="1200" height="475" alt="GHBanner" src="https://github.com/user-attachments/assets/0aa67016-6eaf-458a-adb2-6e31a0763ed6" />
</div>

# Run and deploy your AI Studio app

This contains everything you need to run your app locally.

## Supabase Setup

Before running the app, you need to set up Supabase:
## Run Locally

**Prerequisites:**  Node.js

1. **Connect to Supabase**: Click the "Connect to Supabase" button in the top right to set up your Supabase project
2. **Environment Variables**: The Supabase connection details will be automatically added to your `.env` file
3. **Database Migration**: The database schema will be automatically created when you connect

1. Install dependencies:
   `npm install`
2. Connect to Supabase using the button in the top right
3. (Optional) Set the `GEMINI_API_KEY` in your `.env` file for AI caption generation
3. Run the app:
   `npm run dev`

## Features
**Prerequisites:** Node.js and Supabase account
- **Complete Business Management**: Manage clients, projects, team members, finances, and more
- **Public Forms**: Lead capture, booking, and feedback forms that save directly to your database
- **Client & Freelancer Portals**: Dedicated portals for clients and team members
- **Real-time Data**: All data is stored in Supabase and updates in real-time
- **Mobile Responsive**: Optimized for all devices
## Database Schema
The app uses the following main tables:
- `users` - User accounts and permissions
- `profiles` - Company profile and settings
- `clients` - Client information
- `projects` - Project details and status
- `packages` & `add_ons` - Service packages and add-ons
- `leads` - Lead management
- `transactions` - Financial transactions
- `team_members` - Freelancer/team management
- And many more supporting tables
All tables have Row Level Security (RLS) enabled for data protection.