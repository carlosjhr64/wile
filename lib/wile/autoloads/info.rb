# frozen_string_literal: true

# Wile namespace.
module Wile
  # Info class provides information about the current project.
  # :reek:InstanceVariableAssumption :reek:TooManyInstanceVariables
  # :reek:MissingSafeMethod
  class Info
    using Refinement

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
      @version ||= first_match(@project_rb, /\d+\.\d+\.\d+/).to_s
    end

    private

    def read_rgx(filename)
      Regexp.new read(filename).strip, Regexp::EXTENDED
    end

    # :reek:TooManyStatements
    def set_project!
      @readme     = 'README.md'
      @project    = File.basename(@dirname)
      @gemspec    = "#{@project}.gemspec"
      @module     = @project.pascal_case
      @project_rb = "lib/#{@project}.rb"
      @username   = `git config user.name`.strip
      @email      = `git config user.email`.strip
      @year       = @now.year
      @date       = @now.strftime('%Y-%m-%d')
    end

    def read(filename)
      File.read(filename)
    rescue StandardError
      warn "Warning: using cache #{filename}".red
      File.read("#{@cache}/#{filename}")
    end

    def first_match(filename, regexp)
      md = nil
      File.open(filename, 'r') do |fh|
        while (line = fh.gets)
          return md if (md = regexp.match line)
        end
      end
      warn "no line match: #{regexp} #{filename}".red
      nil
    end
  end
end
