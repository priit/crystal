-- +micrate Up
-- Create menu_items table
CREATE TABLE IF NOT EXISTS menu_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  page_id BIGINT,
  label VARCHAR(255) NOT NULL,
  url VARCHAR(255),
  position INTEGER,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

-- +micrate Down
DROP TABLE IF EXISTS menu_items;
