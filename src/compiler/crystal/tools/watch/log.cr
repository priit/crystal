module Crystal::Watch
  # The log files of `crystal watch --log FILE`, without colors, for a
  # person or an agent to read after the fact:
  #
  # * *FILE* gets what the program run after each build prints, the
  #   watcher's own steps and the errors of failed builds.
  # * *FILE* with `.errors` before its extension (`log/development.errors.log`)
  #   gets only the problems: compilation errors, and the program's
  #   `WARN`/`ERROR`/`FATAL` entries and uncaught exceptions, each with its
  #   following lines (a backtrace).
  #
  # Each build starts with a line `=== build N started HH:MM:SS ===` in both
  # files, numbered as in `crystal watch status`, so the part of the last
  # build is what follows the last such line. Starting the watcher moves the
  # previous files to *FILE*`.1`, and so does a build starting when *FILE*
  # outgrew `MAX_SIZE`.
  class Log
    MAX_SIZE = 10 * 1024 * 1024

    ANSI_ESCAPE = /\e\[[0-9;?]*[A-Za-z]/

    # A line that starts an entry of a log: a time, a date, a severity, or an
    # uncaught exception. Other lines (a backtrace, a multiline message)
    # belong to the entry before them.
    ENTRY_START = /\A(?:\d{1,2}:\d{2}|\d{4}-\d{2}-\d{2}|[A-Z]{4,7}\b|\[watch\]|Unhandled exception)/

    # Where in an entry's first line its severity is.
    SEVERITY_PREFIX = 48
    PROBLEM         = /\b(?:WARN|WARNING|ERROR|FATAL)\b/

    getter path : String
    getter errors_path : String

    @io : File
    @errors : File
    # Per stream (output, error) of the program: whether its current entry
    # is a problem.
    @problem = {false, false}

    def self.errors_path(path : String) : String
      extension = File.extname(path)
      "#{path.rchop(extension)}.errors#{extension.presence || ".log"}"
    end

    # *continue* appends to the files as they are: the watcher restarted
    # itself (see `Watcher#restart_for_full_compilation`).
    def initialize(@path : String, *, continue : Bool = false)
      @errors_path = Log.errors_path(@path)
      Dir.mkdir_p(File.dirname(@path))
      rotate unless continue
      @io = File.open(@path, "a")
      @errors = File.open(@errors_path, "a")
    end

    # Marks the start of build *number*, after moving the files aside when
    # *FILE* grew too big.
    def build_started(number : Int32) : Nil
      if @io.size > MAX_SIZE
        close
        rotate
        @io = File.open(@path, "a")
        @errors = File.open(@errors_path, "a")
      end
      marker = "=== build #{number} started #{Time.local.to_s("%H:%M:%S")} ==="
      write @io, marker
      write @errors, marker
    end

    # A line of the watcher; *problem* also writes it to the errors file.
    def watcher(text : String, problem : Bool = false) : Nil
      text = text.gsub(ANSI_ESCAPE, "")
      write @io, text
      write @errors, text if problem
    end

    # A line the program printed on its standard output, or its standard
    # error when *error*.
    def program(line : String, error : Bool) : Nil
      text = line.chomp.gsub(ANSI_ESCAPE, "")
      if ENTRY_START.matches?(text)
        problem = text.starts_with?("Unhandled exception") || PROBLEM.matches?(text[0, SEVERITY_PREFIX])
        @problem = error ? {@problem[0], problem} : {problem, @problem[1]}
      end
      write @io, text
      write @errors, text if @problem[error ? 1 : 0]
    end

    def close : Nil
      @io.close
      @errors.close
    end

    private def rotate : Nil
      {@path, @errors_path}.each do |file|
        File.rename(file, "#{file}.1") if File.info?(file).try(&.size.positive?)
      end
    rescue IO::Error
      # Best effort: the new lines go after the old ones
    end

    private def write(io : File, text : String) : Nil
      io.puts text
      io.flush
    rescue IO::Error
      # Best effort: never stop the watcher because of its log
    end
  end
end
