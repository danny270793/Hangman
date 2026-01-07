# Supabase Setup Guide

This guide explains how to set up Supabase authentication for the Hangman app.

## Prerequisites

1. Create a Supabase account at [https://supabase.com](https://supabase.com)
2. Create a new project in Supabase

## Configuration Steps

### 1. Get Your Supabase Credentials

1. Go to your Supabase project dashboard
2. Navigate to **Settings** → **API**
3. Copy the following values:
   - **Project URL** (e.g., `https://xxxxx.supabase.co`)
   - **anon public** key (starts with `eyJh...`)

### 2. Update Configuration File

Open `lib/config/supabase_config.dart` and replace the placeholder values:

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL'; // Replace with your Project URL
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY'; // Replace with your anon key
}
```

### 3. Configure Authentication

In your Supabase dashboard:

1. Go to **Authentication** → **Providers**
2. Enable **Email** provider
3. Configure email settings:
   - Enable **Email Confirmations** if you want users to verify their email
   - Configure **SMTP settings** if you want to send custom emails

### 4. Database Setup (Optional)

The authentication is handled by Supabase automatically, but if you want to store additional user data:

1. Go to **Table Editor**
2. Create a `profiles` table with the following columns:
   - `id` (uuid, primary key, references auth.users)
   - `username` (text)
   - `created_at` (timestamp)
   - `updated_at` (timestamp)

3. Set up Row Level Security (RLS) policies for the profiles table

### 5. Test the Integration

1. Run the app: `flutter run`
2. Navigate to the register page
3. Create a new account with email and password
4. Check your Supabase dashboard under **Authentication** → **Users** to see the registered user

## Features Implemented

- ✅ Email/Password registration
- ✅ Email/Password login
- ✅ Logout functionality
- ✅ Authentication state management
- ✅ Error handling with user feedback
- ✅ Loading states during authentication
- ✅ Username storage in user metadata

## Troubleshooting

### Issue: "Invalid API key"
- Make sure you copied the **anon public** key, not the **service_role** key

### Issue: "Failed to sign up"
- Check that the Email provider is enabled in Supabase
- Ensure your password meets the minimum requirements (6 characters)

### Issue: "Email not confirmed"
- If you enabled email confirmations, users need to click the verification link
- You can disable email confirmations in Supabase settings for testing

## Security Notes

⚠️ **Important**: Never commit your actual Supabase credentials to version control!

Consider using environment variables or a secure configuration management solution for production apps.

For Flutter, you can use packages like:
- `flutter_dotenv` for environment variables
- `flutter_secure_storage` for secure local storage

## Next Steps

- Implement password reset functionality
- Add social authentication providers (Google, GitHub, etc.)
- Set up profile management
- Implement email verification flow

