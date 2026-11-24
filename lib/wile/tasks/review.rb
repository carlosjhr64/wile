# frozen_string_literal: true

# wile: require 'reek,rubocop'
# wile: os `clear,reek,rubocop,wile`

# ## wile review ##
# Interactively reviews project files using content, order, reek, and rubocop.
# With --all, auto-advances through passing files and stops only on issues.
#   CSV is a comma separated list: content,order,reek,rubocop
# Usage:
#   wile review [<target>] [--all] [--strict] [--only=CSV] # runs review
module Wile
  # This file is loaded upon a :review task request.
  class Tasks
    REVIEW_USAGE = [
      'review: May take one target with optional all/strict/only flags.',
      (0..1), Set['all', 'strict', 'only']
    ].freeze

    def review(options, target: nil)
      Utilities.project_root? do |missing|
        raise "NOINPUT: Missing root files: #{missing.join(', ')}"
      end
      target ||= Usage.new(options, *REVIEW_USAGE).args&.first
      Review.new(options, Review.review_files(target)).run
    end
  end

  # This class is used to run review.
  # rubocop:disable-next Style/ClassAndModuleChildren
  class Tasks::Review
    using UtilitiesRefinements

    AVAILABLE_CHECKS = %i[content order reek rubocop].freeze

    def self.review_files(target)
      all_files = NvimFiles.new.nvim_files.select { it.start_with?('lib/') }
      return all_files unless target
      return [target] if File.file?(target)

      match_target(all_files, target)
    end

    def self.match_target(all_files, target)
      matched = if File.directory?(target)
                  Dir.glob(File.join(target, '**/*.rb'))
                else
                  all_files.grep(/#{target}/)
                end
      raise "no match for #{target}" if matched.empty?

      matched
    end

    def initialize(options, files)
      @files = files
      @files.weird_filename!
      raise 'No files to review' if @files.empty?

      @index = 0
      @options = options
      @checks = self.class.parse_checks(options.only)
    end

    def self.parse_checks(only)
      return AVAILABLE_CHECKS unless only

      checks = Array(only).join(',').split(',').map(&:to_sym).uniq
      bad = checks - AVAILABLE_CHECKS
      bad.empty? ? checks : raise("Unknown checks: #{bad.join(',')}")
    end

    def run
      catch(:quit) { loop { review_do } }
    end

    private

    def index(match)
      @files.index { |entry| entry.match?(match) } or
        raise "no match for #{match}"
    end

    def review_response_cases(response, size = @files.size)
      case response
      when 'q', 'Q' then throw(:quit)
      when '', 'n', 'N' then @index = (@index + 1) % size
      when 'p', 'P' then @index = (@index - 1) % size
      when 'r', 'R' then nil
      else
        @index = index(response)
      end
    end

    def review_failed
      @checks.reject { send(it) }
    end

    def review_do
      system('clear')
      puts "#{@index + 1}. #{file}".blue.bold
      review_next review_failed
    end

    # :reek:UncommunicativeVariableName e is standard
    def review_next(failed)
      review_response_cases review_choice(failed)
    rescue StandardError => e
      puts e.message.red
      retry
    end

    def auto_next
      @index + 1 < @files.size ? 'n' : 'q'
    end

    def review_choice(failed)
      return auto_next if @options.all? && failed.empty?

      puts "\nFailed: #{failed.join(', ')}".red if failed.any?
      prompt_choice
    end

    def prompt_choice
      print 'Next(Enter) Quit(q) Redo(r) Previous(p) or file match: '.yellow
      $stdin.gets&.strip || 'q'
    end

    def content
      puts "\n# Content".blue
      system("wile content #{file.sw}")
    end

    def file
      @files[@index]
    end

    def reek
      puts "\n# Reek".blue
      cfg = @options.strict? ? '--config .reek-strict.yml' : ''
      system("reek --no-documentation #{cfg} #{file.sw}")
    end

    def rubocop
      puts "\n# Rubocop".blue
      cfg = @options.strict? ? '--config .rubocop-strict.yml' : ''
      system("rubocop #{cfg} #{file.sw}")
    end

    def order
      puts "\n# Order".blue
      sw = file.sw
      system("wile order #{sw}") && system("wile order #{sw} bprm")
    end
  end
  Tasks.private_constant :Review
end
