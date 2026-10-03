-- +micrate Up
-- Create posts table
CREATE TABLE IF NOT EXISTS posts (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id BIGINT,
  category_id BIGINT,
  title VARCHAR(255) NOT NULL,
  slug VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  published BOOLEAN DEFAULT FALSE,
  published_at TIMESTAMP,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

-- +micrate Down
DROP TABLE IF EXISTS posts;
