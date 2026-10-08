module Crystal
  # A lightweight class that discovers all `require`d files WITHOUT performing
  # full semantic analysis. It scans parsed ASTs for Require nodes, resolves
  # filenames via CrystalPath, and recursively discovers transitive requires.
  #
  # Files discovered during macro expansion (which requires semantic analysis)
  # will be missed by this scanner. This is expected -- they fall through to
  # sequential parse in require_file during the semantic phase.
  #
  # The discoverer also handles `{% if flag?(:name) %}` conditionals around
  # requires, since program flags are known at compile start and do not change.
  #
  # Each file is parsed once: the discovered files' ASTs are returned so the
  # semantic phase doesn't parse them again. Files are parsed in waves, the
  # files of one wave in parallel (unless built with `-Dwithout_mt`); the
  # requires found in a wave make up the next one.
  class RequireGraphDiscoverer
    # Files already discovered (absolute paths). Also used to avoid cycles.
    @discovered = Set(String).new

    # Files discovered in the current wave, parsed in the next one.
    @frontier = [] of String

    # The parsed files.
    @parsed = {} of String => ASTNode

    # The program provides crystal_path and flags for require resolution.
    @program : Program

    def initialize(@program : Program, @n_threads : Int32 = 1, @wants_doc : Bool = false)
    end

    # Discovers all files reachable via `require` statements from the initial
    # AST nodes and returns their parsed ASTs, by filename.
    #
    # The prelude require string is also resolved and its files are discovered.
    def discover(initial_nodes : ASTNode, prelude : String) : Hash(String, ASTNode)
      # First, discover the prelude files
      begin
        @program.find_in_path(prelude).try &.each { |filename| enqueue(filename) }
      rescue CrystalPath::NotFoundError
        # Prelude not found -- let the semantic phase handle the error
      end

      # Then scan the initial AST for require nodes
      scan_node(initial_nodes)

      until @frontier.empty?
        wave = @frontier
        @frontier = [] of String
        parse_wave(wave)
        wave.each do |filename|
          if parsed = @parsed[filename]?
            scan_node(parsed)
          end
        end
      end

      @parsed
    end

    private def enqueue(filename : String) : Nil
      return if @program.requires.includes?(filename)
      return unless @discovered.add?(filename)

      @frontier << filename
    end

    private def parse_wave(filenames : Array(String)) : Nil
      {% unless flag?(:without_mt) %}
        n = {@n_threads, filenames.size}.min
        if n > 1
          mutex = Sync::Mutex.new
          channel = Channel(String).new(n * 2)
          wg = WaitGroup.new

          n.times do
            wg.spawn do
              # StringPool isn't thread-safe: one per worker
              string_pool = StringPool.new
              while filename = channel.receive?
                if parsed = parse_file(filename, string_pool)
                  mutex.synchronize { @parsed[filename] = parsed }
                end
              end
            end
          end

          filenames.each { |filename| channel.send(filename) }
          channel.close
          wg.wait
          return
        end
      {% end %}

      string_pool = StringPool.new
      filenames.each do |filename|
        if parsed = parse_file(filename, string_pool)
          @parsed[filename] = parsed
        end
      end
    end

    private def parse_file(filename : String, string_pool : StringPool) : ASTNode?
      parser = Parser.new(File.read(filename), string_pool)
      parser.filename = filename
      parser.wants_doc = @wants_doc
      parser.parse
    rescue InvalidByteSequenceError | Crystal::SyntaxException | IO::Error
      # Skip files that can't be read or parsed -- the semantic phase parses
      # them again and reports the error
    end

    # Walk the AST looking for Require nodes and MacroIf nodes that might
    # contain conditional requires (flag? checks).
    private def scan_node(node : ASTNode) : Nil
      case node
      when Require
        scan_require(node)
      when Expressions
        node.expressions.each { |child| scan_node(child) }
      when MacroIf
        scan_macro_if(node)
      when MacroFor
        # MacroFor can't be statically evaluated; skip its body.
        # Any requires inside will be discovered during semantic.
      else
        # Other node types don't contain top-level requires
      end
    end

    # Resolve a require node and discover all files it points to.
    private def scan_require(node : Require) : Nil
      filename = node.string
      relative_to = node.location.try &.original_filename

      begin
        filenames = @program.find_in_path(filename, relative_to)
      rescue CrystalPath::NotFoundError
        # Can't resolve -- semantic phase will handle the error
        return
      end

      return unless filenames

      filenames.each do |resolved_filename|
        enqueue(resolved_filename)
      end
    end

    # Handle {% if flag?(:name) %} conditionals around requires.
    # Since flags are known at compile start, we can statically evaluate
    # flag? conditions and only scan the appropriate branch.
    private def scan_macro_if(node : MacroIf) : Nil
      flag_result = evaluate_flag_condition(node.cond)

      case flag_result
      when true
        scan_node(node.then)
      when false
        scan_node(node.else)
      else
        # Condition is not a simple flag? check -- scan both branches
        # to be conservative (discover more files than needed is safe)
        scan_node(node.then)
        scan_node(node.else)
      end
    end

    # Try to evaluate a condition as a flag? check.
    # Returns true/false if it's a flag? condition we can evaluate,
    # or nil if we can't determine the result statically.
    private def evaluate_flag_condition(cond : ASTNode) : Bool?
      case cond
      when Call
        if cond.name == "flag?" && cond.obj.nil? && cond.args.size == 1
          arg = cond.args.first
          flag_name = case arg
                      when SymbolLiteral then arg.value
                      when StringLiteral then arg.value
                      else                    return nil
                      end
          return @program.has_flag?(flag_name)
        end
      when Not
        inner = evaluate_flag_condition(cond.exp)
        return !inner if inner != nil
      when And
        left = evaluate_flag_condition(cond.left)
        right = evaluate_flag_condition(cond.right)
        if left != nil && right != nil
          return left && right
        end
      when Or
        left = evaluate_flag_condition(cond.left)
        right = evaluate_flag_condition(cond.right)
        if left != nil && right != nil
          return left || right
        end
      when BoolLiteral
        return cond.value
      end

      nil
    end
  end
end
