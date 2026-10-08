{% skip_file unless flag?(:linux) %}

require "../../../../spec_helper"
require "../../../../../src/compiler/crystal/tools/watch/file_watcher"
require "../../../../../src/compiler/crystal/tools/watch/inotify_watcher"

describe Crystal::Watch::InotifyWatcher do
  it "keeps its inotify descriptor non blocking" do
    watcher = Crystal::Watch::InotifyWatcher.new
    begin
      IO::FileDescriptor.get_blocking(watcher.@inotify_fd).should be_false
    ensure
      watcher.close
    end
  end

  it "returns the changes after the debounce" do
    with_tempfile("inotify_watcher") do |dir|
      Dir.mkdir_p(dir)
      path = File.join(dir, "watched.cr")
      File.write(path, "1")
      watcher = Crystal::Watch::InotifyWatcher.new
      begin
        watcher.watch(Set{path})
        File.write(path, "2")
        watcher.wait_for_changes(10.milliseconds).should eq([path])
      ensure
        watcher.close
      end
    end
  end
end
