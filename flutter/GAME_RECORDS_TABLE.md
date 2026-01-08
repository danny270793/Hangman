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

-- Enable Row Level Security (RLS)
ALTER TABLE game_records ENABLE ROW LEVEL SECURITY;

-- Create policy: Users can only insert their own records
CREATE POLICY "Users can insert their own game records"
ON game_records FOR INSERT
TO authenticated
WITH CHECK (auth.uid() = user_id);

-- Create policy: Users can only view their own records
CREATE POLICY "Users can view their own game records"
ON game_records FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

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

## Table Columns

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

## Row Level Security (RLS)

The table has RLS enabled with the following policies:
- ✅ Users can **INSERT** their own records
- ✅ Users can **SELECT** their own records
- ✅ Users can **UPDATE** their own records
- ✅ Users can **DELETE** their own records
- ❌ Users **CANNOT** access other users' records

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

### Retrieve User's Game Records

```dart
final gameRecordService = GameRecordService();
final records = await gameRecordService.getUserGameRecords();

for (var record in records) {
  print('Score: ${record['points']}, Words: ${record['words']}');
}
```

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

