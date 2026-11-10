# frozen_string_literal: true

# Wile namespace.
module Wile
  # Git module provides functions to interact with git.
  module Git
    def self.init!(directory)
      raise 'git init failed' unless system('git', 'init', directory)
    end

    def self.clean?
      out = `git status --porcelain 2>/dev/null`
      $CHILD_STATUS.exitstatus.zero? && out.empty?
    end

    def self.clean!
      raise 'git status not clean' unless clean?
    end

    def self.diff(*files, options: '--minimal')
      system('git', 'diff', options, *files)
    end

    def self.files
      `git ls-files`.lines.map(&:strip)
    end

    def self.tag!(version)
      raise 'git tag failed' unless
        system('git', 'tag', '-a', version, '-m', version)
    end

    def self.verify_unpublished!(version)
      raise "#{version} found in git tag list... already published!" unless
        `git tag -l #{version}`.strip.empty?
    end

    def self.commit!(version)
      return if system('git', 'commit', '-a', '-m', version)

      raise 'git commit failed'
    end

    def self.push!
      raise 'git push failed' unless system('git', 'push', '--follow-tags')
    end
  end
end
