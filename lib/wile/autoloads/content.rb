# frozen_string_literal: true

# Wile namespace.
module Wile
  # Displays information on methods in a file.
  # :reek:TooManyInstanceVariables :reek:TooManyMethods
  class Content
    using Refinement

    def red? = @red == :red

    # :reek:DuplicateMethodCall iterate
    def initialize(filenames, options)
      @red = @scope = @mlc = @filename = @responds = @casgn = nil
      if options.raw then iterate(filenames)
      else
        Responds.new do |responds|
          @responds = responds
          iterate(filenames)
        end
      end
    end

    private

    MTHD = { content_end: /^end$/, content_def: /^def \w/,
             content_casgn: /^casgn \w/, content_methods: /^  / }.freeze

    TYPES = { 'array' => Array, 'hash' => Hash, 'regexp' => Regexp,
              'str' => String, 'dstr' => String, 'sym' => Symbol,
              'int' => Integer, 'float' => Float, 'Struct' => Class,
              'lambda' => Proc }.freeze

    # pp is autoloaded
    RESERVED_WORDS = %i[private protected public pp using refine].freeze

    CLRS = %i[color_here_def color_here_casgn color_stdlib color_kernel].freeze

    private_constant :MTHD, :TYPES, :RESERVED_WORDS, :CLRS

    def iterate(filenames)
      while (@filename = filenames.shift)
        @mlc = CodeStats.method_line_count(@filename)
        @casgn = {}
        content_scrape
      end
    end

    def content_heading = print "\n#{'#'.gray} #{@filename.bold}\n\n"

    def content_scrape
      content_heading
      pp @mlc unless @responds
      CodeContent.generate(@filename) do |line|
        @responds ? content_display(line.chomp) : (puts line)
      end
    end

    # :reek:UncommunicativeVariableName
    def content_display(line)
      send(MTHD.detect { |_, v| v.match?(line) }&.first || :content_main, line)
    end

    def content_end(_ = nil) = @scope = nil

    # :reek:TooManyStatements
    def color_here_def(name)
      return :green if @mlc.key?(name)
      return nil unless @scope
      if name == '.new'
        return @mlc.key?("#{@scope}#initialize") ? :green : :magenta
      end
      if /^[#.]/.match?(name)
        return @mlc.key?("#{@scope}#{name}") ? :green : nil
      end

      sub_scopes(name)
    end

    # :reek:FeatureEnvy
    def sub_scopes(name, scopes = @scope.split('::'))
      until scopes.empty?
        mth = "#{scopes.join('::')}::#{name}"
        return :green if @mlc.key?(mth)

        scopes.pop
      end

      nil
    end

    def color_stdlib(name) = @responds.ok?(name) ? :light_blue : nil

    # :reek:FeatureEnvy :reek:TooManyStatements
    # :reek:UncommunicativeVariableName
    def content_casgn(line)
      _, fullname, type = line.split
      @casgn[fullname] = type
      parts = fullname.split('::')
      name = parts.pop
      prefix = parts.empty? ? '' : "#{parts.join('::')}::"
      c = TYPES.key?(type) ? :green : :magenta
      puts "#{prefix.light_blue}#{name.bold} #{type.colorize(c)}"
    end

    def content_def(line, fnm = line.split.last)
      name, sep, @scope = fnm.split(/([#.])/).reverse
      print "#{@scope&.light_blue}#{sep&.light_blue}#{name.black.bold}"
      @mlc.key?(fnm) ? puts(" #{@mlc[fnm].to_s.green}") : puts(' ??'.red)
    end

    # :reek:ManualDispatch and :reek:UtilityFunction
    def color_kernel(name, mth = name.strip[1..].to_sym)
      RESERVED_WORDS.include?(mth) || Kernel.respond_to?(mth) ? :cyan : nil
    end

    # :reek:DuplicateMethodCall @casgn[const]
    # :reek:TooManyStatements
    # :reek:UncommunicativeVariableName
    def constant_type(const, type = nil)
      return @casgn[const] unless @scope

      scopes = @scope.split('::')
      until scopes.empty?
        k = "#{scopes.join('::')}::#{const}"
        return type if (type = @casgn[k])

        scopes.pop
      end
      @casgn[const]
    end

    # :reek:ControlParameter
    def color_here_casgn(name)
      return nil unless /^(?<const>[A-Z]\w*)\.(?<mth>\w+[!=?]?)$/ =~ name
      return nil unless (type = constant_type(const))
      return :magenta unless (kls = TYPES[type])

      color kls.public_method_defined?(mth.to_sym) ? :green : nil
    end

    # :reek:ControlParameter
    def color(name) = name || (@red = :red)
    def color_code(name) = color(CLRS.first_truthy_value { send(it, name) })
    def content_main(name) = puts name.colorize(color_code(name))

    def content_methods(line, name = line.strip, color = color_code(name))
      puts "  #{name.colorize(color)}"
    end
  end
end
