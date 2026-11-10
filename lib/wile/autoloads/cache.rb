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

      c2p(File.join(@info.cache, cfile), pfile)
      warn pfile.green
      pfile
    rescue StandardError => e
      warn "#{pfile}: #{e.message}".red
    end

    def pfiles
      files('.')
        .select { %r{^[.]git/hooks/}.match?(it) || !/^[.]git\b/.match?(it) }
    end

    def p2c_hash
      cfiles.to_h { [cfile2pfile(it), it] }
    end

    def make
      dirname = @info.dirname
      FileUtils.mkdir_p(File.dirname(dirname))
      FileUtils.cp_r(@info.cache, dirname)
      erb_convert
      git_init
    end

    private

    # :reek:TooManyStatements
    def git_init
      dirname = @info.dirname
      Git.init! dirname
      git = File.join(dirname, 'git')
      Find.find(git) do |fn|
        next unless File.file?(fn)

        dest = File.join(dirname, '.git', fn.delete_prefix("#{git}/"))
        FileUtils.mkdir_p(File.dirname(dest))
        File.rename(fn, dest)
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

    # :reek:UtilityFunction
    def find(dir)
      [].tap do |res|
        Find.find(dir) do |path|
          if File.directory?(path) && path.start_with?("#{dir}/.git") &&
             path != "#{dir}/.git" && !path.start_with?("#{dir}/.git/hooks")
            Find.prune
          end
          res << path if File.file?(path)
        end
      end
    end

    def c2p(cfile, pfile)
      FileUtils.mkdir_p(File.dirname(pfile))
      if cfile.end_with?('.erb')
        erb_cp(cfile, pfile)
      else
        FileUtils.cp(cfile, pfile)
      end
    end

    def erb_cp(cfile, pfile)
      File.open(pfile, 'w') { it.puts @info.erb_result(cfile) }
      File.chmod(File.stat(cfile).mode, pfile)
    end

    # :reek:TooManyStatements
    def erb_convert
      cache = @info.cache
      dirname = @info.dirname
      Find.find(cache) do |cf|
        next unless cf.end_with?('.erb')

        rel = cf.delete_prefix("#{cache}/")
        erb = File.join(dirname, rel)
        dest = File.join(dirname, cfile2pfile(rel))
        erb_cp(erb, dest)
        File.delete(erb)
      end
    end
  end
end
