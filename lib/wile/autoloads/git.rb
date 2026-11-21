# frozen_string_literal: true

# wile: os `git`

# Wile namespace.
module Wile
  # Git module provides functions to interact with git.
  module Git
    def self.init!(directory)
      git!('init', directory)
    end

    def self.clean?
      out = `git status --porcelain 2>/dev/null`
      $CHILD_STATUS.exitstatus.zero? && out.empty?
    end

    def self.clean!
      raise 'git status not clean' unless clean?
    end

    def self.diff(*files, options: '--minimal')
      Utilities.run('git', 'diff', options, *files)
    end

    def self.files
      `git ls-files`.lines(chomp: true)
    end

    def self.tag!(version)
      git!('tag', '-a', version, '-m', version)
    end

    def self.verify_unpublished!(version)
      raise "#{version} found in git tag list... already published!" unless
        `git tag -l #{version}`.strip.empty?
    end

    def self.add!(*files)
      git!('add', *files)
    end

    # :reek:BooleanParameter :reek:ControlParameter
    def self.commit!(version, no_verify: false)
      args = ['commit', '-a', '-m', version]
      args << '--no-verify' if no_verify
      git!(*args)
    end

    def self.push!
      git!('push', '--follow-tags')
    end

    def self.git!(*)
      Utilities.run('git', *) { |_, msg| raise msg }
    end
    private_class_method :git!
  end
end
