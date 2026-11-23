# frozen_string_literal: true

# Wile namespace.
module Wile
  # Runs a block concurrently over items using a bounded pool of threads.
  class ThreadPool
    def self.default_workers = [1, (Etc.nprocessors * 0.5).round].max

    def initialize(workers: ThreadPool.default_workers)
      @workers = [1, workers].max
      @mutex = Mutex.new
    end

    def self.build_queue(items)
      Thread::Queue.new.tap do |queue|
        items.each { queue << it }
        queue.close
      end
    end

    def reject(items, &)
      queue = ThreadPool.build_queue(items)
      [].tap { |failed| spawn_workers(queue, failed, &) }
    end

    private

    def spawn_workers(queue, failed, &)
      Array.new(@workers) do
        Thread.new { drain(queue, failed, &) }
      end.each(&:join)
    end

    def drain(queue, failed)
      while (item = queue.pop)
        @mutex.synchronize { failed << item } unless yield(item)
      end
    end
  end

  # Test module provides methods to run tests.
  module Test
    # Matches long-running test suites ending in '_slow'. Prioritizes them
    # at the front of the batch queue so worker threads start them immediately,
    # reducing overall completion time across parallel workers.
    SLOW_TESTS = /_slow$/

    def self.test_files
      Dir['test/**/tc_*'].select do |tf|
        File.file?(tf) && %r{/tc_\w+$}.match?(tf)
      end.sort
    end
    private_class_method :test_files

    def self.matched_files(filematch)
      files = test_files
      return files unless filematch

      matched = files.grep(Regexp.new(filematch))
      matched.empty? ? raise("No tests matched: #{filematch}") : matched
    end
    private_class_method :matched_files

    # :reek:ControlParameter
    def self.options(methodmatch, quiet)
      [
        '--verbose=important-only',
        '--ignore-name=test_rubocop_and_reek',
        ('--progress-style=fault-only' if quiet),
        ("--name=/#{methodmatch}/" if methodmatch)
      ].compact
    end
    private_class_method :options

    # :reek:BooleanParameter :reek:ControlParameter
    # :reek:LongParameterList
    def self.test!(filematch = nil, methodmatch = nil,
                   batch: false, list: false, quiet: false)
      files = matched_files(filematch)
      return puts files if list

      opt = options(methodmatch, quiet)
      batch ? batch_test(files, opt) : sequential_test(files, opt)
    end

    def self.sequential_test(files, opt)
      files.each do |tf|
        puts "#{tf}: ".blue
        raise "failed: #{tf}" unless system(tf, *opt) # permit
      end
    end
    private_class_method :sequential_test

    def self.batch_test(files, opt)
      failed = ThreadPool.new.reject(prioritized_files(files)) do |tf|
        system(tf, *opt, out: File::NULL, err: File::NULL) # permit
      end
      report_failures(failed.sort) unless failed.empty?
    end
    private_class_method :batch_test

    def self.prioritized_files(files)
      slow, normal = files.partition { it.match?(SLOW_TESTS) }
      slow + normal
    end
    private_class_method :prioritized_files

    def self.report_failures(failed)
      msg = failed.size == 1 ? failed.first : "\n#{failed.join("\n")}"
      raise "failed: #{msg}"
    end
    private_class_method :report_failures
  end
end
