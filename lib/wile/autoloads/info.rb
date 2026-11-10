# frozen_string_literal: true

# Wile namespace.
module Wile
  # Info class provides information about the current project.
  # :reek:InstanceVariableAssumption :reek:TooManyInstanceVariables
  # :reek:MissingSafeMethod
  class Info
    using WileRefinements

    attr_reader :dirname, :cache, :now, :readme,
                :project, :gemspec, :module, :project_rb,
                :username, :email,
                :year, :date

    def erb_result(filename)
      ERB.new(File.read(filename)).result(binding)
    end

    def self.info(...)
      @info ||= new(...)
    end

    def self.reset!
      @info = nil
    end

    def initialize(dirname: File.expand_path('.'), root: ROOT, now: Time.now)
      @dirname = dirname
      @cache   = File.join(root, 'cache')
      @now     = now
      set_project!
    end

    def verify_version!(vrs)
      raise "current version is #{version}, not #{vrs}" unless version == vrs
    end

    def wileignore
      @wileignore ||= read_rgx('.wileignore')
    end

    def gemignore
      @gemignore ||= read_rgx('.gemignore')
    end

    def version
      @version ||= File.read(File.join(@dirname, '.version')).chomp
    end

    private

    def read_rgx(filename)
      Regexp.new read(filename).strip, Regexp::EXTENDED
    end

    def set_project!
      set_project_names
      set_git_user
      set_date
    end

    def set_project_names
      @readme     = 'README.md'
      @project    = File.basename(@dirname)
      @gemspec    = "#{@project}.gemspec"
      @module     = @project.pascal_case
      @project_rb = "lib/#{@project}.rb"
    end

    def set_git_user
      @username = `git config user.name 2>/dev/null`.strip
      @username = ENV['USER'].to_s if @username.empty?
      @email    = `git config user.email 2>/dev/null`.strip
    end

    def set_date
      @year = @now.year
      @date = @now.strftime('%Y-%m-%d')
    end

    def read(filename)
      File.read(File.join(@dirname, filename))
    rescue StandardError
      warn "Warning: using cache #{filename}".yellow
      File.read(File.join(@cache, filename))
    end
  end
end
