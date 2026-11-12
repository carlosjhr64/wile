# frozen_string_literal: true

# Wile namespace.
module Wile
  # Project module provides methods to manage project files.
  module Project
    using UtilitiesRefinements

    # :reek:TooManyStatements
    def self.archive(pkg)
      pkg.weird_filename!
      raise "Package not found: #{pkg}" unless File.file?(pkg)

      version = pkg.scan(/\d+\.\d+\.\d+/).first
      raise "Cannot extract version from: #{pkg}" unless version

      FileUtils.mkdir_p('pkg')
      File.rename pkg, "pkg/#{pkg}"
      File.open('History.txt', 'a') do |file|
        file.puts "# #{version} / #{Time.now}"
        file.puts `md5sum pkg/#{pkg.sw}`
      end
    end

    def self.find(dir)
      found = []
      Find.find(dir) do |path|
        if git_non_hook?(path)
          Find.prune
        elsif File.file?(path)
          found << path
        end
      end
      found
    end

    def self.files(dir)
      find(dir).map { it.delete_prefix("#{dir}/") }
    end

    def self.pfiles
      files('.')
        .select { %r{^[.]git/hooks/}.match?(it) || !/^[.]git\b/.match?(it) }
    end

    def self.rbfiles
      Git.files.select { /\.rb$/.match?(it) || bang_ruby?(it) }
    end

    def self.bang_ruby?(filename)
      return false unless File.file?(filename) &&
                          !File.empty?(filename) &&
                          File.executable?(filename) &&
                          !/\.erb$/.match?(filename)

      first_line = File.read(filename, 80).lines.first
      first_line ? /^#!.*\bruby\b/.match?(first_line.rstrip) : false
    end

    def self.git_non_hook?(path)
      return false unless File.directory?(path)

      parts = path.split('/')
      return false unless (idx = parts.rindex('.git'))
      return false if idx == parts.length - 1

      parts[idx + 1] != 'hooks'
    end
  end
end
