-- +micrate Up
-- Create medias table
CREATE TABLE IF NOT EXISTS medias (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id BIGINT,
  filename VARCHAR(255) NOT NULL,
  content_type VARCHAR(255),
  byte_size BIGINT,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

-- +micrate Down
DROP TABLE IF EXISTS medias;
