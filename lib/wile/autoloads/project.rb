# frozen_string_literal: true

# Wile namespace.
module Wile
  # Project module provides methods to manage project files.
  module Project
    def self.archive(pkg)
      version = pkg.scan(/\d+\.\d+\.\d+/).first
      File.rename pkg, "pkg/#{pkg}"
      File.open('History.txt', 'a') do |file|
        file.puts "# #{version} / #{Time.now}"
        file.puts `md5sum pkg/#{Shellwords.escape(pkg)}`
      end
    end

    def self.find(dir)
      Find.find(dir).select { File.file? it }
    end

    def self.files(dir)
      find(dir).map { it.delete_prefix("#{dir}/") }
    end

    def self.pfiles
      files('.')
        .select { %r{^[.]git/hooks/}.match?(it) || !/^[.]git\b/.match?(it) }
    end

    # :reek:ControlParameter
    def self.rbfiles(mode = nil)
      (mode == :git ? Git.files : pfiles)
        .select { /\.rb$/.match? it or bang_ruby? it }
    end

    def self.bang_ruby?(filename)
      return false if /\.erb$/.match?(filename) || !File.executable?(filename)

      /^#!.*\bruby$/.match? File.read(filename, 80).lines.first.rstrip
    end
  end
end
