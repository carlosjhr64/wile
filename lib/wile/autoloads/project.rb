# frozen_string_literal: true

# wile: os `md5sum`

# Wile namespace.
module Wile
  # Project module provides methods to manage project files.
  module Project
    using UtilitiesRefinements

    def self.archive(pkg)
      pkg.weird_filename!
      raise "Package not found: #{pkg}" unless File.file?(pkg)

      version = pkg.scan(/\d+\.\d+\.\d+/).first
      raise "Cannot extract version from: #{pkg}" unless version

      record_history(version, pkg)
    end

    def self.record_history(version, pkg)
      FileUtils.mkdir_p('pkg')
      File.rename(pkg, "pkg/#{pkg}")
      File.open('History.txt', 'a') do |file|
        file.puts "# #{version} / #{Time.now}"
        file.puts `md5sum pkg/#{pkg.sw}`
      end
    end
    private_class_method :record_history

    def self.find(dir)
      files = Git.files
      return files if %w[. ./].include?(dir)

      prefix = "#{dir.delete_prefix('./').delete_suffix('/')}/"
      files.select { it.start_with?(prefix) }
    end

    def self.files(dir)
      find(dir).map { it.delete_prefix("#{dir.delete_prefix('./')}/") }
    end

    def self.pfiles = Git.files

    def self.bang_ruby?(filename)
      return false unless File.file?(filename) &&
                          !File.empty?(filename) &&
                          File.executable?(filename) &&
                          !/\.erb$/.match?(filename)

      first_line = File.read(filename, 80).lines.first
      first_line ? /^#!.*\bruby\b/.match?(first_line.rstrip) : false
    end

    def self.rbfiles
      Git.files.select { /\.rb$/.match?(it) || bang_ruby?(it) }
    end
  end
end
