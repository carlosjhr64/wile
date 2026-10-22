# frozen_string_literal: true

# Wile namespace.
module Wile
  # Project module provides methods to manage project files.
  # :reek:DataClump cfile pfile
  class Cache
    attr_reader :info

    # :reek:BooleanParameter
    def initialize(info = Info.info, trace: false)
      @info = info
      @trace = trace
    end

    # :reek:BooleanParameter :reek:TooManyStatements
    # :reek:UncommunicativeVariableName e is standard
    def copy2project(cfile, pfile = cfile2pfile(cfile), force: false)
      if !force && File.exist?(pfile)
        warn pfile.light_black if @trace
        return false
      end

      c2p("#{@info.cache}/#{cfile}", pfile)
      warn pfile.green
      pfile
    rescue StandardError => e
      warn "#{pfile}: #{e.message}".red # returns nil
    end

    def pfiles
      files('.')
        .select { %r{^[.]git/hooks/}.match?(it) || !/^[.]git\b/.match?(it) }
    end

    def p2c_hash
      Hash[*cfiles.map { [cfile2pfile(it), it] }.flatten]
    end

    def make
      FileUtils.cp_r @info.cache, @info.dirname
      erb_convert
      git_init
    end

    private

    # :reek:DuplicateMethodCall @info.dirname
    def git_init
      Git.init! @info.dirname
      # Add template's hooks
      git = File.join(@info.dirname, 'git')
      Find.find(git) do |fn|
        File.rename(fn, fn.sub('/git/', '/.git/')) if File.file?(fn)
      end
      FileUtils.rm_r(git)
    end

    def cfile2pfile(cfile)
      cfile.chomp('.erb')
           .sub(%r{/project(\.\w+)?$}, "/#{@info.project}\\1")
           .sub(/^git\b/, '.git')
    end

    def files(dir)
      find(dir).map { it.delete_prefix("#{dir}/") }
    end

    def cfiles(ignore: @info.wileignore, cache: @info.cache)
      files(cache).grep_v(ignore)
    end

    def find(dir)
      Find.find(dir).select { File.file? it }
    end

    def c2p(cfile, pfile)
      case cfile
      when /\.erb$/
        erb_cp(cfile, pfile)
      when /pre-commit$/
        FileUtils.cp cfile, '.git/hooks/pre-commit'
      else
        FileUtils.cp cfile, pfile
      end
    end

    def erb_cp(cfile, pfile)
      File.open(pfile, 'w') { it.puts @info.erb_result(cfile) }
      File.chmod(File.stat(cfile).mode, pfile)
    end

    # :reek:TooManyStatements
    def erb_convert(dirname: @info.dirname,
                    cache: @info.cache,
                    project: @info.project)
      Find.find(cache) do |cf| # cache file
        next unless /\.erb$/.match?(cf)

        # Note that these are now only *.erb files...
        erb = File.join(dirname, cf.delete_prefix(cache))
        fn = erb.chomp('.erb')
        erb_cp(erb, fn)
        File.rename fn, fn.sub(/project(\.\w+)?$/, "#{project}\\1")
        File.delete erb
      end
    end
  end
end
