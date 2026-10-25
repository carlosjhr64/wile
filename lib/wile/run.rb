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
      if (name = @options.task) && (task = @tasks.find(name))
        require_relative "tasks/#{task}"
        @tasks.method(task).call(@options)
      else
        help(name)
      end
    end

    def help(name)
      raise UsageError, "list: No tasks matched '#{name}'" if name

      require_relative 'tasks/help'
      @tasks.help(@options)
    end

    def handle_usage_error
      warn @error.message.lines.map { it.chomp.blue }
                 .tap { it[-1] = it[-1].chomp.red }.join("\n")
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
      warn @error.backtrace[0..3].reverse.join("\n").blue
      warn @error.message.red
      exit EX_SOFTWARE
    end
  end
end
