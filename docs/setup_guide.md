# Setup Guide

This guide covers everything needed to set up **QuoteVault** from scratch, including the backend Supabase configuration.

## 1. Supabase Setup

### A. Create Project
1.  Go to [supabase.com](https://supabase.com/).
2.  Create a fresh project.
3.  Note down the **Project URL** and **Anon Key**.

### B. Authentication
1.  Go to **Authentication** -> **Providers**.
2.  Enable **Email/Password**.
3.  Disable "Confirm email" if you want instant signup (optional).

### C. Database Schema
Run the following SQL in the Supabase **SQL Editor** to create the tables.

```sql
-- 1. Create Profiles Table (Public User Data)
create table profiles (
  id uuid references auth.users not null primary key,
  updated_at timestamp with time zone,
  full_name text,
  avatar_url text,
  website text
);

-- 2. Favorites Table
create table favorites (
  id uuid default uuid_generate_v4() primary key,
  user_id uuid references auth.users not null,
  quote_id text not null, -- ID from the Quote API or local DB
  text text not null,
  author text not null,
  category text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- 3. RLS Policies
alter table profiles enable row level security;
alter table favorites enable row level security;

-- Profiles: Public Read, Auth Update
create policy "Public profiles are viewable by everyone."
  on profiles for select
  using ( true );

create policy "Users can insert their own profile."
  on profiles for insert
  with check ( auth.uid() = id );

create policy "Users can update own profile."
  on profiles for update
  using ( auth.uid() = id );

-- Favorites: Private CRUD
create policy "Users can view own favorites"
  on favorites for select
  using ( auth.uid() = user_id );

create policy "Users can create favorites"
  on favorites for insert
  with check ( auth.uid() = user_id );

create policy "Users can delete favorites"
  on favorites for delete
  using ( auth.uid() = user_id );
```

### D. Storage (Optional for Avatars)
1.  Create a new bucket named `avatars`.
2.  Set it to Public.

---

## 2. Flutter Configuration

### A. Environment Variables
QuoteVault uses `lib/main.dart` initialization. Ensure you update the Supabase configuration.

**File**: `lib/main.dart` (or wherever your `Supabase.initialize` call is)

```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_SUPABASE_ANON_KEY',
);
```

### B. Dependencies
Ensure you have the correct Flutter version.

```bash
flutter doctor
# Verify Flutter 3.0+
```

Run dependencies:

```bash
flutter pub get
```

---

## 3. Running the App

### Android
```bash
flutter run -d android
```

### iOS
```bash
cd ios
pod install
cd ..
flutter run -d ios
```
