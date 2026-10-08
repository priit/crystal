require "../../../../spec_helper"
require "../../../../../src/compiler/crystal/tools/watch/log"

private def read_log(dir, name)
  File.read(File.join(dir, name))
end

describe Crystal::Watch::Log do
  it "names the errors file after the log" do
    Crystal::Watch::Log.errors_path("log/development.log").should eq("log/development.errors.log")
    Crystal::Watch::Log.errors_path("out").should eq("out.errors.log")
  end

  it "moves the previous files aside when started" do
    with_tempfile("watch_log") do |dir|
      path = File.join(dir, "log", "development.log")
      Crystal::Watch::Log.new(path).tap(&.watcher("first")).close
      Crystal::Watch::Log.new(path).tap(&.watcher("second")).close

      read_log(dir, "log/development.log").should eq("second\n")
      read_log(dir, "log/development.log.1").should eq("first\n")
    end
  end

  it "goes on in the same files for a watcher that restarted itself" do
    with_tempfile("watch_log") do |dir|
      path = File.join(dir, "development.log")
      Crystal::Watch::Log.new(path).tap(&.watcher("first")).close
      Crystal::Watch::Log.new(path, continue: true).tap(&.watcher("second")).close

      read_log(dir, "development.log").should eq("first\nsecond\n")
      File.exists?(File.join(dir, "development.log.1")).should be_false
    end
  end

  it "marks builds and keeps the problems apart, without colors" do
    with_tempfile("watch_log") do |dir|
      log = Crystal::Watch::Log.new(File.join(dir, "development.log"))
      log.build_started(4)
      log.program("06:12:03 Server     | \e[36mSELECT 1\e[0m\n", error: false)
      log.program("06:12:04 Error: 500 | (ERROR) Boom\n", error: false)
      log.program("src/app.cr:3:1 in 'boom'\n", error: false)
      log.program("06:12:05 Server     | (INFO) GET /\n", error: false)
      log.program("Unhandled exception: Oops (Exception)\n", error: true)
      log.program("  from src/app.cr:9:1 in 'run'\n", error: true)
      log.watcher("[watch] Compilation failed", problem: true)
      log.close

      lines = read_log(dir, "development.log").lines
      lines.first.should match(/\A=== build 4 started \d\d:\d\d:\d\d ===\z/)
      lines[1].should eq("06:12:03 Server     | SELECT 1")
      lines.size.should eq(8)

      read_log(dir, "development.errors.log").lines[1..].should eq([
        "06:12:04 Error: 500 | (ERROR) Boom",
        "src/app.cr:3:1 in 'boom'",
        "Unhandled exception: Oops (Exception)",
        "  from src/app.cr:9:1 in 'run'",
        "[watch] Compilation failed",
      ])
    end
  end
end
