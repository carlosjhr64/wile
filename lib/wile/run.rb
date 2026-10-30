# frozen_string_literal: true

# Wile namespace.
module Wile
  using Refinement

  PASCAL_KEY = ->(str) { str.pascal_case.to_sym }

  def self.autoloads
    Dir.glob("#{__dir__}/autoloads/*.rb")
       .map { File.basename(it, '.rb') }
       .each { autoload PASCAL_KEY[it], "wile/autoloads/#{it}" }
  end

  # The Run class is responsible for executing the Wile application.
  # :reek:UncommunicativeVariableName e is standard
  class Run
    include Sysexits

    def initialize(options)
      @options = options
      @error = nil
      require_relative 'requires'
      Wile.autoloads
      @tasks = Wile::Tasks.new
      run
    rescue StandardError => e
      @error = e
      handle_error
    end

    private

    def run
      return man unless (name = @options.task)

      if (task = @tasks.find(name))
        require_relative "tasks/#{task}"
        @tasks.method(task).call(@options)
      else
        # The 'list:' prefix tells UsageError to prepend Help[:list] usage.
        raise UsageError, "list: No tasks matched '#{name}'"
      end
    end

    def man
      path = File.join(Wile::ROOT, 'man/wile.1')
      if $stdout.tty? && File.file?(path)
        exec('man', '-l', path)
      else
        path = File.join(Wile::ROOT, 'man/wile.md')
        puts File.read(path) if File.exist?(path)
      end
    end

    def handle_usage_error
      msg = @error.message
      lines = msg.lines.map(&:chomp)
      lines = lines[...-1].map(&:blue) << lines[-1]&.red
      warn lines.compact.join("\n")
      exit EX_USAGE
    end

    def handle_error
      case @error
      when UsageError
        handle_usage_error
      when RuntimeError
        handle_runtime_error
      else
        handle_software_error
      end
    end

    def handle_runtime_error
      warn @error.message.red
      exit EX_FAIL
    end

    def handle_software_error
      if (backtrace = @error.backtrace)
        warn backtrace[0..3].reverse.join("\n").blue
      end
      warn @error.message.red
      exit EX_SOFTWARE
    end
  end
end
