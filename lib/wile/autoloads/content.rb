# frozen_string_literal: true

# Wile namespace.
module Wile
  # Displays information on methods in a file.
  class Content
    MTHD = { content_end: /^end$/, content_def: /^def [#.\w]/,
             content_attr: /^#attr_(?:reader|writer|accessor) /,
             content_casgn: /^casgn \w/, content_methods: /^  / }.freeze
    private_constant :MTHD

    def red? = @red

    def self.format_casgn(fullname, type)
      prefix, sep, name = fullname.rpartition('::')
      color = Colorizer.known_type?(type) ? :green : :magenta
      "#{"#{prefix}#{sep}".light_blue}#{name.bold} #{type.colorize(color)}"
    end

    def initialize(filenames, options)
      @red = false
      @colorizer = nil
      if options.raw
        dump_files(filenames)
      else
        Responds.new { |resp| filenames.each { display_file(it, resp) } }
      end
    end

    def self.format_member(fnm)
      name, sep, scope = fnm.split(/([#.])/).reverse
      [scope, "#{scope&.light_blue}#{sep&.light_blue}#{name.bold}"]
    end

    def self.heading(file) = print "\n#{'#'.gray} #{file.bold}\n\n"

    private

    def dump_files(filenames) = filenames.each { dump_file(it) }

    def content_casgn(line)
      _, fullname, type = line.split
      @colorizer.record_casgn(fullname, type)
      puts Content.format_casgn(fullname, type)
    end

    def dump_file(filename)
      Content.heading(filename)
      pp CodeStats.method_line_count(filename)
      CodeContent.generate(filename) { |line| puts line }
    end

    def display_file(filename, responds)
      Content.heading(filename)
      @colorizer = Colorizer.new(
        CodeStats.method_line_count(filename), responds
      )
      CodeContent.generate(filename) { |line| content_display(line.chomp) }
    end

    def content_attr(line)
      fnm = line.split.last
      @colorizer.record_attr(fnm)
      _, label = Content.format_member(fnm)
      puts "#{label} #{'0'.green}"
    end

    def content_def(line)
      fnm = line.split.last
      scope, label = Content.format_member(fnm)
      count = @colorizer.enter_def(scope, fnm)
      puts "#{label} #{count ? count.to_s.green : '??'.red}"
    end

    def content_display(line)
      key = MTHD.detect { |_, pat| pat.match?(line) }&.first || :content_main
      send(key, line)
    end

    def content_end(_ = nil) = @colorizer.leave_scope

    def content_methods(line)
      name = line.strip
      puts "  #{name.colorize(color_code(name))}"
    end

    def color_code(name)
      color = @colorizer.resolve(name)
      @red = true if color == :red
      color
    end

    def content_main(name) = puts name.colorize(color_code(name))
  end

  # Resolves display colors for scraped method and constant references.
  # rubocop:disable-next Style/ClassAndModuleChildren
  class Content::Colorizer
    using WileRefinements

    TYPES = {
      'array' => Array, 'hash' => Hash, 'regexp' => Regexp,
      'str' => String, 'dstr' => String, 'sym' => Symbol,
      'int' => Integer, 'float' => Float, 'Struct' => Class, 'lambda' => Proc
    }.freeze

    # pp is autoloaded
    RESERVED_WORDS = %i[private protected public pp using refine
                        module_function].freeze

    CLRS = %i[color_here_def color_here_casgn color_stdlib].freeze

    private_constant :RESERVED_WORDS, :CLRS

    def enter_def(scope, fnm)
      @scope = scope
      @mlc[fnm]
    end

    def initialize(mlc, responds)
      @mlc = mlc
      @responds = responds
      @casgn = {}
      @scope = nil
    end

    def leave_scope = @scope = nil

    def record_attr(fnm) = @mlc[fnm] = 0

    def record_casgn(fullname, type) = @casgn[fullname] = type

    def self.duck?(name) = name.match?(/\A(?:\*|(?:[@$]{1,2})?[a-z_]\w*)#/)

    def resolve(name)
      kls = self.class
      return :gray if kls.duck?(name)

      CLRS.first_truthy_value { send(it, name) } ||
        (kls.kernel?(name) ? :cyan : :red)
    end

    def self.kernel?(name)
      mth = name.strip[1..].to_sym
      RESERVED_WORDS.include?(mth) || Kernel.methods.include?(mth)
    end

    def self.known_type?(type) = TYPES.key?(type)

    private

    def color_here_def(name)
      return :green if @mlc.key?(name)
      return nil unless @scope

      scoped_def_color(name)
    end

    def scoped_def_color(name)
      if name == '.new'
        return @mlc.key?("#{@scope}#initialize") ? :green : :magenta
      end
      return :green if /^[#.]/.match?(name) && @mlc.key?("#{@scope}#{name}")

      :green if scope_prefixes.any? { @mlc.key?("#{it}#{name}") }
    end

    def scope_prefixes
      return [] unless @scope

      parts = @scope.split('::')
      parts.size.downto(1).map { "#{parts[0, it].join('::')}::" }
    end

    def constant_type(const)
      keys = scope_prefixes.map { "#{it}#{const}" } << const
      keys.first_truthy_value { @casgn[it] }
    end

    def color_here_casgn(name)
      const, mth = name.split('.')
      return nil unless mth && (type = constant_type(const))
      return :magenta unless (kls = TYPES[type])

      kls.public_method_defined?(mth.to_sym) ? :green : :red
    end

    def color_stdlib(name)
      kls = "#{@scope}#{name}" if @scope && /^[.#]/.match?(name)
      targets = kls ? [kls, "#{@scope.split('::').last}#{name}"] : [name]
      :light_blue if targets.any? { @responds.ok?(it) }
    end
  end
  Content.private_constant :Colorizer
end
