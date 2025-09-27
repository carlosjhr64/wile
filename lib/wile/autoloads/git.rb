# frozen_string_literal: true

# Wile namespace.
module Wile
  # Git module provides functions to interact with git.
  module Git
    def self.init!(directory)
      raise 'git init failed' unless system("git init #{directory}")
    end

    def self.clean?
      `git status --porcelain`.empty?
    end

    def self.clean!
      raise 'git status not clean' unless clean?
    end

    def self.diff(*files, options: '--minimal')
      system "git diff #{options} #{files.join(' ')}"
    end

    def self.files
      `git ls-files`.lines.map(&:strip)
    end

    def self.tag!(version)
      raise 'git tag failed' unless system("git tag '#{version}'")
    end

    def self.already_published!(version)
      raise "#{version} found in git tag list... already published!" if
      `git tag --list`.split.include?(version)
    end

    def self.commit!(version)
      raise 'git commit failed' unless system("git commit -a -m '#{version}'")
    end

    def self.push!
      raise 'git push failed' unless system('git push')
    end
  end
end
