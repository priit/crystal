require "amber"
require "grant"
require "grant/adapter/sqlite"

Grant::Connections << Grant::Adapter::Sqlite.new(
  name: "primary",
  url: ENV["DATABASE_URL"]? || Amber.settings.database_url
)
