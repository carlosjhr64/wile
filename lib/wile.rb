# frozen_string_literal: true

# The Wile module is the main namespace for the Wile application.
module Wile
  VERSION = '0.0.261023'
  ROOT = File.expand_path('..', __dir__)

  def self.autoloads
    Dir.glob("#{__dir__}/wile/autoloads/*.rb")
       .map { File.basename(it, '.rb') }
       .each { autoload PASCAL_KEY[it], "wile/autoloads/#{it}" }
  end

  # The Run class is responsible for executing the Wile application.
  # :reek:UncommunicativeVariableName e is standard
  class Run
    def initialize(options)
      @options = options
      @error = nil
      require_relative 'wile/requires'
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
        require_relative "wile/tasks/#{task}"
        @tasks.method(task).call(@options)
      else
        help(name)
      end
    end

    def help(name)
      raise UsageError, "list: No tasks matched '#{name}'" if name

      require_relative 'wile/tasks/help'
      @tasks.help(@options)
    end

    def handle_usage_error
      warn @error.message.lines.map { it.chomp.blue }
                 .tap { it[-1] = it[-1].chomp.red }.join("\n")
      exit 64 # Usage
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
      exit 1 # Regular
    end

    def handle_software_error
      warn @error.backtrace[0..3].reverse.join("\n").blue
      warn @error.message.red
      exit 70 # Software
    end
  end
end
