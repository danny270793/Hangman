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

### 2. Update Environment Variables

Create a `.env` file in the project root (it's already in `.gitignore`):

```bash
cp .env.example .env
```

Then edit `.env` and replace the placeholder values:

```env
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

**Note**: The `.env` file is ignored by git to keep your credentials secure. Never commit this file!

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

✅ **Good News**: Your credentials are now stored in `.env` which is automatically ignored by git!

The `.env` file is added to `.gitignore`, so it won't be committed to version control. This keeps your credentials secure.

**Best Practices:**
- Never commit the `.env` file to version control
- Share `.env.example` with your team (without actual credentials)
- Each developer should create their own `.env` file locally
- Use different Supabase projects for development, staging, and production

## Environment Variables

The app uses `flutter_dotenv` to load environment variables from `.env`:

```env
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

These are accessed in `lib/config/supabase_config.dart` using:
```dart
dotenv.env['SUPABASE_URL']
dotenv.env['SUPABASE_ANON_KEY']
```

## Next Steps

- Implement password reset functionality
- Add social authentication providers (Google, GitHub, etc.)
- Set up profile management
- Implement email verification flow

