-- +micrate Up
-- Create profiles table
CREATE TABLE IF NOT EXISTS profiles (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id BIGINT,
  website VARCHAR(255),
  location VARCHAR(255),
  avatar_url VARCHAR(255),
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

-- +micrate Down
DROP TABLE IF EXISTS profiles;
