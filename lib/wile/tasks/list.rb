# frozen_string_literal: true

# ## wile list ##
# Available formats:
#   * USAGE default
#   * DICTIONARY
#   * NAME
#   * CODE
# Usage:
#   wile list [<match>+] [--format=WORD] # list tasks(by match)
module Wile
  # This file is loaded upon a :list task request.
  # :reek:InstanceVariableAssumption
  class Tasks
    LIST_USAGE = [
      'list: Optionally takes one or more tasks with optional format flag.',
      Set['format']
    ].freeze

    def list(options, tasks = @tasks)
      args = Usage.new(options, *LIST_USAGE).args
      TaskLister.new(tasks, args, options.format || 'USAGE').display
    end
  end

  # Formats and displays matching Wile tasks.
  # rubocop:disable-next Style/ClassAndModuleChildren
  class Tasks::TaskLister
    FORMATS = {
      'USAGE' => :puts_usage,
      'DICTIONARY' => :puts_dictionary,
      'NAME' => :puts_name,
      'CODE' => :puts_code
    }.freeze

    def initialize(tasks, args = nil, format = 'USAGE')
      @tasks = tasks
      @args = args
      @format = format
    end

    def self.parse_usage(task)
      usage, comment = Help.usage(task).split(/\s*#\s*/, 2)
      cmd, name, args = usage.split(/\s+/, 3)
      [cmd, name, args, comment]
    end

    def display
      matched = matched_tasks
      raise 'No task matched' if matched.empty?

      display_tasks(matched, FORMATS.fetch(resolve_format))
    end

    private

    def puts_dictionary(task)
      _cmd, name, _args, comment = self.class.parse_usage(task)
      puts "+ #{name}: #{comment || '-'}"
    end

    def puts_usage(task)
      cmd, name, args, comment = self.class.parse_usage(task)
      puts(comment ? "# #{comment.capitalize}:".gray : '# ---'.gray)
      puts ["  #{cmd}", name.blue.bold, args].compact.join('  ')
    end

    def matched_tasks
      @args ? @tasks.select { match?(it) } : @tasks
    end

    def display_tasks(tasks, formatter)
      puts
      tasks.each { send(formatter, it) }
      puts
    end

    def match?(task)
      @args.any? { task.match?(it) }
    end

    def resolve_format
      fmt = @format.upcase
      return fmt if FORMATS.key?(fmt)

      raise UsageError, "list: Unrecognized format '#{@format}'."
    end

    def puts_code(task)
      puts Help.usage(task)
    end

    def puts_name(task)
      puts task
    end
  end
  Tasks.private_constant :TaskLister
end
