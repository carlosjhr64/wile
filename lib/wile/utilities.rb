# frozen_string_literal: true

# Wile namespace.
module Wile
  # Utility functions collected and harmonized from bin/bootstrap_* scripts.
  # :reek:NilCheck
  # :reek:TooManyStatements
  # rubocop:disable-next Metrics/ModuleLength
  module Utilities
    include Sysexits

    module_function

    # category: lookup
    # --- Path & Executable Lookup ---

    # Used in: missing_packages (internal helper)
    def package_installed?(pkg)
      `dpkg-query -W -f='${db:Status-Status}' #{pkg} 2>/dev/null`.strip ==
        'installed'
    end

    # Used in: bootstrap_ruby_rbenv
    def missing_packages(packages)
      packages.reject { |pkg| package_installed?(pkg) }
    end

    # Used in: bootstrap_install_neovim
    def check_path_notice(dir)
      return if paths.include?(dir)

      warn "Notice: #{dir} is not currently in your PATH.".yellow
    end

    # Used in: check_path_notice, which (internal helper)
    def paths
      ENV.fetch('PATH', '').split(File::PATH_SEPARATOR)
    end

    # Used in: bootstrap_system_commands
    def check_commands(commands)
      commands.reject do |cmd|
        path = which(cmd)
        puts "#{cmd} found: #{path}".green if path
        path
      end
    end

    # Used in: bootstrap_fish, bootstrap_install_neovim, bootstrap_ruby_rbenv
    def which(cmd)
      paths.each do |dir|
        bin = File.join(dir, cmd)
        return bin if File.file?(bin) && File.executable?(bin)
      end
      nil
    end

    # Used in: bootstrap_system_commands
    def missing_commands(commands)
      commands.reject { |cmd| command_available?(cmd) }
    end

    # Used in: bootstrap_install_neovim
    def verify_utilities!(utilities)
      missing = missing_commands(utilities)
      return if missing.empty?

      error!(EX_UNAVAILABLE,
             'Error: Required utilities not found in PATH: ' \
             "#{missing.join(', ')}")
    end

    # Used in: bootstrap_fish, bootstrap_fisher_plugins, bootstrap_ruby_rbenv
    def command_available?(cmd)
      !which(cmd).nil?
    end

    # category: prompts
    # --- User Prompts & Error Handling ---

    # Used in: bootstrap_fish, bootstrap_fisher_plugins,
    #          bootstrap_install_neovim, bootstrap_ruby_gems,
    #          bootstrap_ruby_rbenv, bootstrap_system_commands
    def confirm?(prompt)
      print "#{prompt.yellow} [y/N]: "
      $stdout.flush
      reply = $stdin.gets
      return false unless reply

      /^[Yy]([Ee][Ss])?$/.match?(reply.strip)
    end

    # Used in: bootstrap_fish, bootstrap_fisher_plugins,
    #          bootstrap_install_neovim, bootstrap_ruby_gems,
    #          bootstrap_ruby_rbenv, bootstrap_system_commands
    def error!(val, msg)
      warn msg.red
      exit val
    end

    # category: environment
    # --- Platform & Environment Checks ---

    ROOT_FILES = %w[.version .ruby-version Gemfile].freeze

    # Used in: bootstrap_install_neovim
    def verify_arch!(arch = 'x86_64')
      detected = `uname -m`.strip
      return if detected == arch

      error!(EX_UNAVAILABLE,
             "Error: #{arch} architecture required (detected: #{detected}).")
    end

    # Used in: bootstrap_fish, bootstrap_install_neovim,
    #          bootstrap_system_commands
    def verify_linux!
      os = `uname -s`.strip
      return if os == 'Linux'

      error!(EX_UNAVAILABLE,
             "Error: Wile is meant to be run on Linux (detected: #{os}).")
    end

    # Used in: bootstrap_ruby_gems
    def verify_project_root!(root_files = ROOT_FILES)
      root_files.each do |file|
        next if File.file?(file) && !File.empty?(file)

        error!(EX_NOINPUT, "Error: #{file} not found -- " \
                           "run this from a Wile project's root directory.")
      end
    end

    # Used in: bootstrap_fish, bootstrap_ruby_gems
    # :reek:BooleanParameter
    # rubocop:disable-next Metrics/MethodLength
    def verify_rbenv!(require_in_path: false, re_run: nil)
      rbenv = File.expand_path('~/.rbenv/bin/rbenv')
      ready = File.executable?(rbenv) &&
              (!require_in_path || command_available?('rbenv'))
      if ready
        puts "rbenv found: #{`rbenv --version`.strip}".green if require_in_path
        return
      end

      detail =
        if require_in_path
          'not found or not initialized in PATH'
        else
          "not found at #{rbenv}"
        end
      re_run_hint = re_run ? ", then re-run:\n  #{re_run}" : '.'
      error!(EX_UNAVAILABLE, <<~MSG)
        Error: rbenv #{detail}.
        Run ./bin/bootstrap_ruby_rbenv first#{re_run_hint}
      MSG
    end

    # Used in: bootstrap_fisher_plugins
    def verify_ruby_min_version!(min_version = '4.0', re_run: nil, note: nil)
      if version_ok?(RUBY_VERSION, min_version)
        puts "Ruby verified: #{RUBY_DESCRIPTION}".green
        return
      end

      note = " by #{note}" if note
      re_run_hint = re_run ? ", then re-run:\n  #{re_run}" : '.'
      msg = "Error: Ruby >= #{min_version} is required#{note} " \
            "(found: #{RUBY_VERSION}).\n" \
            "Run ./bin/bootstrap_ruby_rbenv first#{re_run_hint}\n"
      error!(EX_UNAVAILABLE, msg)
    end

    # Used in: bootstrap_fish, bootstrap_fisher_plugins,
    #          bootstrap_install_neovim
    def version_ok?(version, min_version)
      # This is strictly greater than or equal, not a "twiddle-wakka".
      Gem::Version.new(version) >= Gem::Version.new(min_version)
    end

    # Used in: bootstrap_ruby_rbenv (and verify_ruby_project_version!)
    def rbenv_root
      `rbenv root 2>/dev/null`.strip
    end

    # Used in: bootstrap_ruby_gems
    # rubocop:disable-next Metrics/MethodLength
    def verify_ruby_project_version!(version_file = '.ruby-version',
                                     re_run: nil)
      expected = File.read(version_file).strip
      expected_prefix = "#{rbenv_root}/versions/#{expected}/"
      ruby_path = RbConfig.ruby

      if expected == RUBY_VERSION && ruby_path.start_with?(expected_prefix)
        puts "Ruby verified: #{RUBY_DESCRIPTION} (#{ruby_path})".green
        return
      end

      re_run_hint = re_run ? ", then re-run:\n  #{re_run}" : '.'
      error!(EX_CONFIG, <<~MSG)
        Error: Expected rbenv Ruby #{expected} (from #{version_file}),
        but current ruby is #{RUBY_VERSION} at #{ruby_path}.

        Ensure ./bin/bootstrap_ruby_rbenv has been run and rbenv shims
        are active in your shell#{re_run_hint}
      MSG
    end

    # category: probing
    # --- Version Probing ---

    # Used in: bootstrap_fish, bootstrap_fisher_plugins
    def fish_version
      return nil unless command_available?('fish')

      `fish --version 2>/dev/null`[/\d+\.\d+/]
    end

    # Used in: bootstrap_fisher_plugins
    def fisher_version
      `fish -c 'fisher --version' 2>/dev/null`[/\d+\.\d+/]
    end

    # Used in: bootstrap_ruby_rbenv
    def gem_installed?(gem_name, env: {})
      system(env, 'gem', 'list', '-i', "^#{gem_name}$",
             out: File::NULL, err: File::NULL)
    end

    # category: execution
    # --- Subprocess Execution ---

    # Used in: bootstrap_fisher_plugins
    def run_fish!(cmd)
      return if system('fish', '-c', cmd, in: File::NULL)

      error!(EX_OSERR, "Error: `fish -c '#{cmd}'` failed.")
    end

    # Used in: bootstrap_install_neovim, bootstrap_ruby_gems,
    #          bootstrap_ruby_rbenv
    def run_cmd!(*cmd, env: {})
      return if system(env, *cmd)

      prefix = env.map { |key, val| "#{key}=#{val} " }.join
      error!(EX_OSERR, "Error: '#{prefix}#{cmd.join(' ')}' failed.")
    end

    # Used in: bootstrap_fish, bootstrap_ruby_rbenv, bootstrap_system_commands
    def apt_install!(packages)
      system('sudo', 'apt-get', 'update') ||
        error!(EX_OSERR, 'Error: apt-get update failed.')
      system('sudo', 'apt-get', 'install', '-y', *packages) ||
        error!(EX_OSERR, "Error: apt-get install #{packages.join(' ')} failed.")
    end
  end
end
