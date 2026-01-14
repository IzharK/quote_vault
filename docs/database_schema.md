# QuoteVault Database Schema (Supabase)

## Tables

### 1. `profiles`
Extends the default Supabase auth user.
- `id` (uuid, PK, references auth.users.id)
- `full_name` (text, nullable)
- `avatar_url` (text, nullable)
- `updated_at` (timestamptz)

### 2. `quotes`
Stores the curated list of quotes.
- `id` (bigint/uuid, PK)
- `content` (text, not null)
- `author` (text, not null)
- `category` (text, not null) - e.g., 'Motivation', 'Love', 'Success', 'Wisdom', 'Humor'
- `created_at` (timestamptz, default now())

### 3. `favorites`
Join table for users liking quotes.
- `id` (bigint/uuid, PK)
- `user_id` (uuid, FK references profiles.id)
- `quote_id` (FK references quotes.id)
- `created_at` (timestamptz, default now())
- **Constraint**: Unique combo of (user_id, quote_id)

### 4. `collections`
User-created lists of quotes.
- `id` (bigint/uuid, PK)
- `user_id` (uuid, FK references profiles.id)
- `name` (text, not null) - e.g., "Morning Motivation"
- `created_at` (timestamptz, default now())

### 5. `collection_items`
Quotes inside a collection.
- `id` (bigint/uuid, PK)
- `collection_id` (FK references collections.id)
- `quote_id` (FK references quotes.id)
- `created_at` (timestamptz, default now())
- **Constraint**: Unique combo of (collection_id, quote_id)

## Security (RLS Policies)

- **profiles**:
    - Public read.
    - Users can update their own profile.
- **quotes**:
    - Public read.
    - Insert/Update restricted to service role (admin) only.
- **favorites**:
    - Users can CRUD their own favorites.
- **collections**:
    - Users can CRUD their own collections.
- **collection_items**:
    - Users can CRUD items in their own collections.
