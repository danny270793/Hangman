# Game Records Table Schema

This document describes the database table structure needed in Supabase to store game records.

## Table Name: `game_records`

### SQL Schema

Run this SQL in your Supabase SQL Editor to create the table:

```sql
-- Create the game_records table
CREATE TABLE game_records (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    has_timed_mode_enabled BOOLEAN NOT NULL,
    difficulty TEXT NOT NULL CHECK (difficulty IN ('easy', 'medium', 'hard')),
    points INTEGER NOT NULL DEFAULT 0,
    words INTEGER NOT NULL DEFAULT 0,
    time_playing INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create an index on user_id for faster queries
CREATE INDEX idx_game_records_user_id ON game_records(user_id);

-- Create an index on created_at for sorting
CREATE INDEX idx_game_records_created_at ON game_records(created_at DESC);

-- Create an index on points for leaderboard
CREATE INDEX idx_game_records_points ON game_records(points DESC);

-- Create a view that joins game_records with auth.users to get usernames
CREATE OR REPLACE VIEW game_records_with_usernames AS
SELECT 
    gr.id,
    gr.user_id,
    COALESCE(
        (au.raw_user_meta_data->>'username')::text,
        'Player'
    ) as username,
    gr.has_timed_mode_enabled,
    gr.difficulty,
    gr.points,
    gr.words,
    gr.time_playing,
    gr.created_at
FROM game_records gr
LEFT JOIN auth.users au ON gr.user_id = au.id;

-- Enable Row Level Security (RLS)
ALTER TABLE game_records ENABLE ROW LEVEL SECURITY;

-- Create policy: Users can only insert their own records
CREATE POLICY "Users can insert their own game records"
ON game_records FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Create policy: Anyone can view all records (for leaderboard)
CREATE POLICY "Anyone can view game records"
ON game_records FOR SELECT
TO authenticated
USING (true);

-- Grant access to the view
GRANT SELECT ON game_records_with_usernames TO authenticated;

-- Create policy: Users can only update their own records
CREATE POLICY "Users can update their own game records"
ON game_records FOR UPDATE
TO authenticated
USING (auth.uid() = user_id);

-- Create policy: Users can only delete their own records
CREATE POLICY "Users can delete their own game records"
ON game_records FOR DELETE
TO authenticated
USING (auth.uid() = user_id);
```

## Table Columns (`game_records`)

| Column | Type | Description | Constraints |
|--------|------|-------------|-------------|
| `id` | UUID | Primary key | Auto-generated |
| `user_id` | UUID | Reference to auth.users | Foreign Key, NOT NULL |
| `has_timed_mode_enabled` | BOOLEAN | Whether timed mode was enabled | NOT NULL |
| `difficulty` | TEXT | Game difficulty level | NOT NULL, CHECK (easy, medium, hard) |
| `points` | INTEGER | Total score earned | NOT NULL, DEFAULT 0 |
| `words` | INTEGER | Number of words solved | NOT NULL, DEFAULT 0 |
| `time_playing` | INTEGER | Total seconds played | NOT NULL, DEFAULT 0 |
| `created_at` | TIMESTAMP | When the record was created | DEFAULT NOW() |

## View Columns (`game_records_with_usernames`)

The view adds the `username` column by joining with `auth.users`:

| Column | Type | Description | Source |
|--------|------|-------------|--------|
| All columns above | - | Inherited from game_records | game_records table |
| `username` | TEXT | Player's username | auth.users.raw_user_meta_data->>'username' |

## Row Level Security (RLS)

The table has RLS enabled with the following policies:
- ✅ Users can **INSERT** their own records
- ✅ **Anyone authenticated** can **SELECT** all records (for leaderboard)
- ✅ Users can **UPDATE** their own records
- ✅ Users can **DELETE** their own records

The view `game_records_with_usernames`:
- ✅ **Anyone authenticated** can **SELECT** from the view
- ✅ Automatically joins usernames from `auth.users` metadata

## Usage in Flutter

The `GameRecordService` class provides methods to interact with this table:

### Save a Game Record

```dart
final gameRecordService = GameRecordService();

final error = await gameRecordService.saveGameRecord(
  hasTimedModeEnabled: true,
  difficulty: 'medium',
  points: 250,
  words: 5,
  timePlaying: 180,
);

if (error != null) {
  print('Error saving game record: $error');
} else {
  print('Game record saved successfully!');
}
```

### Retrieve All Game Records (Leaderboard)

```dart
final gameRecordService = GameRecordService();
final records = await gameRecordService.getAllGameRecords(limit: 100);

for (var record in records) {
  print('${record['username']}: ${record['points']} points, ${record['words']} words');
}
```

**Note:** The `username` field is automatically fetched from `auth.users` via the database view, so you don't need to store it when saving records.

## Setup Instructions

1. Open your Supabase project dashboard
2. Go to the **SQL Editor**
3. Copy and paste the SQL schema above
4. Click **Run** to create the table and policies
5. Verify the table was created in the **Table Editor**

## Notes

- All game records are automatically associated with the authenticated user
- Records are sorted by `created_at` in descending order (newest first)
- The `time_playing` field stores seconds as an integer
- The `difficulty` field is constrained to: 'easy', 'medium', or 'hard'

