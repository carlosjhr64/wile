# frozen_string_literal: true

# ## wile list ##
# Usage:
#   wile list [<match>+] [--list] # list tasks(by match)
module Wile
  # This file is loaded upon a :list task request.
  # :reek:InstanceVariableAssumption
  class Tasks
    LIST_USAGE = ['list: Optionally takes one or more tasks.',
                  Set['list']].freeze

    # :reek:NestedIterators :reek:TooManyStatements
    def list(options, tasks = @tasks)
      if (args = Usage.new(options, *LIST_USAGE).args)
        tasks = @tasks.select { |tsk| args.any? { |arg| tsk.match?(arg) } }
      end
      raise 'No task matched' if tasks.empty?

      puts
      tasks.each do |task|
        options.list? ? puts_task(task) : puts_usage(task)
      end
      puts
    end

    private

    def puts_task(task)
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
