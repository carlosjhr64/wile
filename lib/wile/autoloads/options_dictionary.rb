# frozen_string_literal: true

module Wile
  # OptionsDictionary holds metadata for allow-listed options and reports
  # on their usage when invoked.
  # rubocop:disable-next Metrics/ClassLength
  class OptionsDictionary
    PATTERNS = {
      'WORD' => /\A[\w-]+\z/,
      'CSV' => /\A[\w-]+(,[\w-]+)*\z/,
      'FILE' => %r{\A(/?[\w.][\w.-]*)+/?\z},
      'ATTRS' => /\A[a-zA-Z]+(,[a-zA-Z]+)*\z/,
      'MODE' => /\A[0-7]{3,4}\z/,
      'INTEGER' => /\A\d+\z/,
      'DECIMAL' => /\A\d+(\.\d+)?\z/,
      'PATTERN' => /\A\S+\z/,
      'USER' => /\A([a-zA-Z_])[\w-]*\z/,
      'WHEN' => /\A(always|auto|never)\z/,
      'URL' => %r{\A([a-zA-Z]+://\S+|[\w.-]+@\S+)\z}
    }.freeze

    OPTIONS = {
      'all' => {
        desc: 'Apply to all targets',
        type: nil,
        commands: %w[ls du df git]
      },
      'archive' => {
        desc: 'Archive mode; preserve file attributes and permissions',
        type: nil,
        commands: %w[cp rsync tar]
      },
      'backup' => {
        desc: 'Make backup before removal or overwrite',
        type: nil,
        commands: %w[cp mv]
      },
      'batch' => {
        desc: 'Run in non-interactive batch mode',
        type: nil,
        commands: %w[sed make git]
      },
      'check' => {
        desc: 'Run in check-only mode',
        type: nil,
        commands: %w[sort git]
      },
      'clean' => {
        desc: 'Remove build artifacts and temporary files',
        type: nil,
        commands: %w[git make]
      },
      'color' => {
        desc: 'Control colored output (always, auto, never)',
        type: 'WHEN',
        commands: %w[ls grep diff git]
      },
      'config' => {
        desc: 'Configuration file path',
        type: 'FILE',
        commands: %w[rubocop reek man]
      },
      'context' => {
        desc: 'Number of lines of context to display',
        type: 'INTEGER',
        commands: %w[grep diff]
      },
      'count' => {
        desc: 'Print count of matching items instead of contents',
        type: nil,
        commands: %w[grep wc]
      },
      'delete' => {
        desc: 'Delete extraneous or target files',
        type: nil,
        commands: %w[rsync git]
      },
      'dereference' => {
        desc: 'Follow symbolic links',
        type: nil,
        commands: %w[ls cp tar]
      },
      'detailed' => {
        desc: 'Display detailed output',
        type: nil,
        commands: %w[curl rsync tar]
      },
      'diff' => {
        desc: 'Show differences between files or states',
        type: nil,
        commands: %w[git patch]
      },
      'directory' => {
        desc: 'Change to directory before operating',
        type: 'FILE',
        commands: %w[tar git make]
      },
      'dump' => {
        desc: 'Dump internal structure or data',
        type: nil,
        commands: %w[file strings git]
      },
      'encoding' => {
        desc: 'Character encoding to use',
        type: 'WORD',
        commands: %w[iconv ruby]
      },
      'exclude' => {
        desc: 'Exclude files or paths matching pattern',
        type: 'PATTERN',
        commands: %w[tar grep rsync]
      },
      'follow' => {
        desc: 'Output appended data as file grows',
        type: nil,
        commands: %w[tail]
      },
      'force' => {
        desc: 'Force execution without safety checks',
        type: nil,
        commands: %w[cp mv rm ln git]
      },
      'format' => {
        desc: 'Output format',
        type: 'WORD',
        commands: %w[rubocop reek cucumber]
      },
      'git' => {
        desc: 'Operate on git-tracked files',
        type: nil,
        commands: ['"reserved for custom tasks"']
      },
      'header' => {
        desc: 'Display or include header line',
        type: nil,
        commands: %w[curl ps tar]
      },
      'help' => {
        desc: 'Show help summary',
        type: nil,
        commands: %w[git reek rubocop]
      },
      'icase' => {
        desc: 'Ignore case distinctions in patterns or text',
        type: nil,
        commands: %w[grep diff sort]
      },
      'include' => {
        desc: 'Include only files or paths matching pattern',
        type: 'PATTERN',
        commands: %w[grep rsync]
      },
      'interactive' => {
        desc: 'Prompt before overwrite or action',
        type: nil,
        commands: %w[cp mv rm git]
      },
      'interval' => {
        desc: 'Time to wait between repetitions',
        type: 'DECIMAL',
        commands: %w[watch ping]
      },
      'jobs' => {
        desc: 'Number of concurrent jobs or tasks',
        type: 'INTEGER',
        commands: %w[make ninja xargs]
      },
      'limit' => {
        desc: 'Limit the number of results or records',
        type: 'INTEGER',
        commands: %w[git sqlite3]
      },
      'linenumber' => {
        desc: 'Print line number with output lines',
        type: nil,
        commands: %w[grep]
      },
      'list' => {
        desc: 'List items',
        type: nil,
        commands: %w[reek docker git]
      },
      'logfile' => {
        desc: 'Path to log file',
        type: 'FILE',
        commands: %w[wget git]
      },
      'maxdepth' => {
        desc: 'Descend at most INTEGER directory levels',
        type: 'INTEGER',
        commands: %w[find du]
      },
      'mode' => {
        desc: 'File permission mode (octal or symbolic)',
        type: 'MODE',
        commands: %w[chmod install mkdir]
      },
      'name' => {
        desc: 'Filter or match by name',
        type: 'WORD',
        commands: %w[find docker]
      },
      'nocache' => {
        desc: 'Bypass cache and fetch fresh data',
        type: nil,
        commands: %w[curl pacman]
      },
      'only' => {
        desc: 'Select only specified items',
        type: 'CSV',
        commands: %w[rsync]
      },
      'output' => {
        desc: 'Write output to file',
        type: 'FILE',
        commands: %w[sort curl wget]
      },
      'parents' => {
        desc: 'Create intermediate parent directories as needed',
        type: nil,
        commands: %w[mkdir cp]
      },
      'port' => {
        desc: 'Port number to connect or listen to',
        type: 'INTEGER',
        commands: %w[curl ssh]
      },
      'preserve' => {
        desc: 'Preserve specified file attributes',
        type: 'ATTRS',
        commands: %w[cp]
      },
      'quiet' => {
        desc: 'Suppress non-essential output',
        type: nil,
        commands: %w[grep curl rsync]
      },
      'raw' => {
        desc: 'Raw / unformatted output',
        type: nil,
        commands: %w[netcat curl git]
      },
      'readable' => {
        desc: 'Print human readable output',
        type: nil,
        commands: %w[ls du df]
      },
      'recursive' => {
        desc: 'Operate recursively on directories',
        type: nil,
        commands: %w[cp rm rsync grep]
      },
      'remote' => {
        desc: 'Remote repository or server address',
        type: 'URL',
        commands: %w[git rsync]
      },
      'reverse' => {
        desc: 'Reverse sorting order of results',
        type: nil,
        commands: %w[ls sort]
      },
      'simulate' => {
        desc: 'Simulate execution without making changes',
        type: nil,
        commands: %w[rsync git make]
      },
      'sort' => {
        desc: 'Sort output by specified key or field',
        type: 'WORD',
        commands: %w[ls sort ps]
      },
      'status' => {
        desc: 'Display operational status or summary',
        type: nil,
        commands: %w[git service docker]
      },
      'strict' => {
        desc: 'Enable strict mode',
        type: nil,
        commands: %w[perl]
      },
      'sync' => {
        desc: 'Synchronize data to storage before exiting',
        type: nil,
        commands: %w[dd cp]
      },
      'tag' => {
        desc: 'Tag name or label to apply or filter by',
        type: 'WORD',
        commands: %w[git docker]
      },
      'target' => {
        desc: 'Target file, directory, or architecture',
        type: 'FILE',
        commands: %w[cp make]
      },
      'timeout' => {
        desc: 'Maximum time to wait before timing out',
        type: 'DECIMAL',
        commands: %w[curl timeout ssh]
      },
      'trace' => {
        desc: 'Trace execution',
        type: nil,
        commands: %w[strace ruby rake]
      },
      'user' => {
        desc: 'Run as or filter by user',
        type: 'USER',
        commands: %w[curl chown docker ps]
      },
      'version' => {
        desc: 'Show version number',
        type: nil,
        commands: %w[git diff reek rubocop]
      },
      'yes' => {
        desc: 'Assume yes to confirmation prompts',
        type: nil,
        commands: %w[apt-get yum]
      }
    }.freeze

    def initialize(options)
      options.to_h.each do |key, value|
        next unless (entry = OPTIONS[key.to_s])

        report(key, value, entry)
      end
    end

    private

    # :reek:TooManyStatements
    def report(key, value, entry)
      type = entry[:type]
      puts type ? "--#{key}=#{value}" : "--#{key}"
      puts "  Description: #{entry[:desc]}"
      puts "  Pattern:     #{type} (/#{PATTERNS[type].source}/)" if type
      puts "  Commands:    #{entry[:commands].join(', ')}"
    end
  end
end
