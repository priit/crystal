-- +micrate Up
-- Create pages table
CREATE TABLE IF NOT EXISTS pages (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title VARCHAR(255) NOT NULL,
  slug VARCHAR(255) NOT NULL,
  body TEXT,
  position INTEGER,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

-- +micrate Down
DROP TABLE IF EXISTS pages;
