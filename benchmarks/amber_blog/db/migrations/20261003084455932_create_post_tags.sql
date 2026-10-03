-- +micrate Up
-- Create post_tags table
CREATE TABLE IF NOT EXISTS post_tags (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  post_id BIGINT,
  tag_id BIGINT,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

-- +micrate Down
DROP TABLE IF EXISTS post_tags;
