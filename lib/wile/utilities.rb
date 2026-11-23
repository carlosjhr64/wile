# frozen_string_literal: true

# wile: os `apt-get,dpkg-query,fish,rbenv,sudo,uname`

# Wile namespace.
module Wile
  # Utility functions collected and harmonized from bin/bootstrap_* scripts.
  # :reek:DataClump
  # :reek:NilCheck
  # :reek:TooManyStatements
  # rubocop:disable-next Metrics/ModuleLength
  module Utilities
    using UtilitiesRefinements
    include Sysexits

    module_function

    # --- Path & Executable Lookup ---
    # category: lookup

    def package_installed?(pkg)
      `dpkg-query -W -f='${db:Status-Status}' #{pkg.sw} 2>/dev/null`
        .strip == 'installed'
    end

    def missing_packages(packages)
      packages.reject { |pkg| package_installed?(pkg) }
    end

    def check_path_notice(dir)
      return if paths.include?(dir)

      warn "Notice: #{dir} is not currently in your PATH.".yellow
    end

    def paths
      ENV.fetch('PATH', '').split(File::PATH_SEPARATOR)
    end

    def check_commands(commands)
      commands.reject do |cmd|
        path = which(cmd)
        puts "#{cmd} found: #{path}".green if path
        path
      end
    end

    def which(cmd)
      paths.each do |dir|
        bin = File.join(dir, cmd)
        return bin if File.file?(bin) && File.executable?(bin)
      end
      nil
    end

    def missing_commands(commands)
      commands.reject { |cmd| command_available?(cmd) }
    end

    def verify_utilities!(utilities)
      missing = missing_commands(utilities)
      return if missing.empty?

      error!(EX_UNAVAILABLE,
             'Error: Required utilities not found in PATH: ' \
             "#{missing.join(', ')}")
    end

    def command_available?(cmd)
      !which(cmd).nil?
    end

    # --- User Prompts & Error Handling ---
    # category: prompts

    def confirm?(prompt)
      print "#{prompt.yellow} [y/N]: "
      $stdout.flush
      reply = $stdin.gets
      return false unless reply

      /^[Yy]([Ee][Ss])?$/.match?(reply.strip)
    end

    def error!(val, msg)
      warn msg.red
      exit val
    end

    # --- Platform & Environment Checks ---
    # category: environment

    ROOT_FILES = %w[.version .ruby-version Gemfile].freeze

    def verify_arch!(arch = 'x86_64')
      detected = `uname -m`.strip
      return if detected == arch

      error!(EX_UNAVAILABLE,
             "Error: #{arch} architecture required (detected: #{detected}).")
    end

    def verify_linux!
      os = `uname -s`.strip
      return if os == 'Linux'

      error!(EX_UNAVAILABLE,
             "Error: Wile is meant to be run on Linux (detected: #{os}).")
    end

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

    def version_ok?(version, min_version)
      # This is strictly greater than or equal, not a "twiddle-wakka".
      Gem::Version.new(version) >= Gem::Version.new(min_version)
    end

    def verify_project_root!(root_files = ROOT_FILES)
      project_root?(root_files) do |missing|
        error!(EX_NOINPUT, "Error: #{missing.first} not found -- " \
                           "run this from a Wile project's root directory.")
      end
    end

    def rbenv_root
      `rbenv root 2>/dev/null`.strip
    end

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

    def project_root?(root_files = ROOT_FILES)
      missing = missing_root_files(root_files)
      return true if missing.empty?

      yield missing if block_given?
      false
    end

    def missing_root_files(root_files = ROOT_FILES)
      root_files.reject { |file| File.file?(file) }
    end

    # --- Version Probing ---
    # category: probing

    def fish_version
      return nil unless command_available?('fish')

      `fish --version 2>/dev/null`[/\d+\.\d+/]
    end

    def fisher_version
      `fish -c 'fisher --version' 2>/dev/null`[/\d+\.\d+/]
    end

    def gem_installed?(gem_name, version: nil, env: {})
      args = ['gem', 'list', '-i', "^#{gem_name}$"]
      args.push('-v', version) if version
      system(env, *args, out: File::NULL, err: File::NULL) # permit
    end

    # --- Subprocess Execution ---
    # category: execution

    def run_fish!(cmd)
      return if system('fish', '-c', cmd, in: File::NULL)

      error!(EX_OSERR, "Error: `fish -c '#{cmd}'` failed.")
    end

    # :reek:BooleanParameter
    # :reek:ControlParameter
    # :reek:LongParameterList
    # rubocop:disable-next Metrics/ParameterLists
    def run!(*cmd, sysexit: nil, msg: nil, stderr: true, echo: false, env: {})
      run(*cmd, stderr:, echo:, env:) do |inferred, default_msg|
        error!(sysexit || inferred, msg || default_msg)
      end
    end

    def apt_install!(packages)
      system('sudo', 'apt-get', 'update') ||
        error!(EX_OSERR, 'Error: apt-get update failed.')
      system('sudo', 'apt-get', 'install', '-y', *packages) ||
        error!(EX_OSERR, "Error: apt-get install #{packages.join(' ')} failed.")
    end

    def infer_sysexit(cmd, res)
      if res.nil?
        exe = cmd.first.to_s.split.first.to_s
        present = File.exist?(exe) || command_available?(exe)
        return present ? EX_NOPERM : EX_UNAVAILABLE
      end
      { 127 => EX_UNAVAILABLE, 126 => EX_NOPERM }
        .fetch($CHILD_STATUS&.exitstatus, EX_OSERR)
    end

    # :reek:BooleanParameter
    # :reek:ControlParameter
    # :reek:LongParameterList
    # rubocop:disable-next Naming/PredicateMethod
    def run(*cmd, stderr: true, echo: false, env: {})
      warn format_cmd(cmd, env).gray if echo
      opts = stderr ? {} : { err: File::NULL }
      return true if (res = system(env, *cmd, **opts)) # permit

      if block_given?
        sysexit = infer_sysexit(cmd, res)
        yield sysexit, default_run_msg(cmd, env, sysexit)
      end
      false
    end

    def format_cmd(cmd, env)
      prefix = env.map { |key, val| "#{key}=#{val.sw} " }.join
      "#{prefix}#{cmd.join(' ')}"
    end

    def default_run_msg(cmd, env, sysexit)
      code = $CHILD_STATUS&.exitstatus
      info = code ? "exit #{code}" : "sysexit #{sysexit}"
      "Error: '#{format_cmd(cmd, env)}' failed (#{info})."
    end
  end
end
