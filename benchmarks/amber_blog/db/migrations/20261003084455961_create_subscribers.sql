-- +micrate Up
-- Create subscribers table
CREATE TABLE IF NOT EXISTS subscribers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  email VARCHAR(255) NOT NULL,
  confirmed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

-- +micrate Down
DROP TABLE IF EXISTS subscribers;
