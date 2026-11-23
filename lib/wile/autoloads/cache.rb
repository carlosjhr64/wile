# frozen_string_literal: true

# Wile namespace.
module Wile
  # Manages template files in cache/ and scaffolds new Wile projects.
  class Cache
    attr_reader :info

    # :reek:BooleanParameter
    def initialize(info = Info.info, trace: false)
      @info = info
      @trace = trace
    end

    def self.prune_git?(path, dir)
      git = "#{dir}/.git"
      File.directory?(path) && path.start_with?(git) &&
        path != git && !path.start_with?("#{git}/hooks")
    end

    def self.move_git_file(file, git, dirname)
      dest = File.join(dirname, '.git', file.delete_prefix("#{git}/"))
      FileUtils.mkdir_p(File.dirname(dest))
      File.rename(file, dest)
    end

    def self.find(dir)
      [].tap do |res|
        Find.find(dir) do |path|
          Find.prune if prune_git?(path, dir)
          res << path if File.file?(path)
        end
      end
    end

    def self.install_git_files(git, dirname)
      Find.find(git) { move_git_file(it, git, dirname) if File.file?(it) }
      FileUtils.rm_r(git)
    end

    def pfiles
      files('.')
        .select { %r{^[.]git/hooks/}.match?(it) || !/^[.]git\b/.match?(it) }
    end

    def make
      dirname = @info.dirname
      FileUtils.mkdir_p(File.dirname(dirname))
      FileUtils.cp_r(@info.cache, dirname)
      erb_convert
      git_init
    end

    # :reek:BooleanParameter :reek:UncommunicativeVariableName
    def copy2project(cfile, pfile = cfile2pfile(cfile), force: false)
      return false if !force && skip_existing?(pfile)

      c2p(cfile, pfile)
    rescue StandardError => e
      warn "#{pfile}: #{e.message}".red
    end

    def p2c_hash = cfiles.to_h { [cfile2pfile(it), it] }

    private

    def files(dir) = Cache.find(dir).map { it.delete_prefix("#{dir}/") }

    def git_init
      dirname = @info.dirname
      Git.init!(dirname)
      Cache.install_git_files(File.join(dirname, 'git'), dirname)
    end

    def cfiles(ignore: @info.wileignore, cache: @info.cache)
      files(cache).grep_v(ignore)
    end

    def skip_existing?(pfile)
      return false unless File.exist?(pfile)

      warn pfile.light_black if @trace
      true
    end

    def cfile2pfile(cfile)
      cfile.chomp('.erb')
           .sub(%r{/project(\.\w+)?$}, "/#{@info.project}\\1")
           .sub(/^git\b/, '.git')
    end

    def erb_convert
      cache = @info.cache
      dirname = @info.dirname
      Find.find(cache) do |file|
        convert_erb(file, cache, dirname) if file.end_with?('.erb')
      end
    end

    def c2p(rel, dest)
      FileUtils.mkdir_p(File.dirname(dest))
      copy_template(File.join(@info.cache, rel), dest)
      warn dest.green
      dest
    end

    def convert_erb(file, cache, dirname)
      rel = file.delete_prefix("#{cache}/")
      erb = File.join(dirname, rel)
      erb_cp(erb, File.join(dirname, cfile2pfile(rel)))
      File.delete(erb)
    end

    def copy_template(src, dest)
      src.end_with?('.erb') ? erb_cp(src, dest) : FileUtils.cp(src, dest)
    end

    def erb_cp(src, dest)
      File.open(dest, 'w') { it.puts @info.erb_result(src) }
      File.chmod(File.stat(src).mode, dest)
    end
  end
end
