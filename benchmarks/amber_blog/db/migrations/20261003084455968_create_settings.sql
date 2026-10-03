-- +micrate Up
-- Create settings table
CREATE TABLE IF NOT EXISTS settings (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  key VARCHAR(255) NOT NULL,
  value TEXT,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

-- +micrate Down
DROP TABLE IF EXISTS settings;
