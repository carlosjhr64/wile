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
    FORMATS = {
      'USAGE' => :puts_usage,
      'DICTIONARY' => :puts_dictionary,
      'NAME' => :puts_name,
      'CODE' => :puts_code
    }.freeze

    LIST_USAGE = [
      'list: Optionally takes one or more tasks with optional format flag.',
      Set['format']
    ].freeze

    # :reek:NestedIterators :reek:TooManyStatements
    def list(options, tasks = @tasks)
      if (args = Usage.new(options, *LIST_USAGE).args)
        tasks = @tasks.select { |tsk| args.any? { |arg| tsk.match?(arg) } }
      end
      raise 'No task matched' if tasks.empty?

      format = options.format || 'USAGE'
      display_tasks(tasks, FORMATS[resolve_format(format)])
    end

    private

    def display_tasks(tasks, formatter)
      puts
      tasks.each { send(formatter, it) }
      puts
    end

    def resolve_format(format)
      fmt = format.upcase
      return fmt if FORMATS.key?(fmt)

      raise UsageError, "list: Unrecognized format '#{format}'."
    end

    def puts_name(task)
      puts task
    end

    def puts_code(task)
      puts Help.usage(task)
    end

    def puts_dictionary(task)
      usage, comment = Help.usage(task).split(/\s*#\s*/, 2)
      _cmd, task, _args = usage.split(/\s+/, 3)
      puts "+ #{task}: #{comment || '-'}"
    end

    # :reek:TooManyStatements
    def puts_usage(task)
      usage, comment = Help.usage(task).split(/\s*#\s*/, 2)
      cmd, task, args = usage.split(/\s+/, 3)
      puts comment ? "# #{comment.capitalize}:".gray : '# ---'.gray
      print "  #{cmd}  #{task.blue.bold}"
      print "  #{args}" if args
      puts
    end
  end
end
