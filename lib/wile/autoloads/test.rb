# frozen_string_literal: true

# Wile namespace.
module Wile
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

    # :reek:ControlParameter
    def self.options(methodmatch, quiet)
      opt = %w[--verbose=important-only --ignore-name=test_rubocop_and_reek]
      opt << '--progress-style=fault-only' if quiet
      opt << "--name=/#{methodmatch}/" if methodmatch
      opt
    end
    private_class_method :options

    def self.prioritized_files(files)
      slow, normal = files.partition { it.match?(SLOW_TESTS) }
      slow + normal
    end
    private_class_method :prioritized_files

    def self.batch_worker(queue, opt, state)
      while (tf = queue.pop)
        state[:mutex].synchronize { state[:failed] << tf } unless
          system(tf, *opt, out: File::NULL, err: File::NULL)
      end
    end
    private_class_method :batch_worker

    def self.run_workers(limit, queue, opt)
      state = { failed: [], mutex: Mutex.new }
      Array.new(limit) do
        Thread.new { batch_worker(queue, opt, state) }
      end.each(&:join)
      state[:failed].sort
    end
    private_class_method :run_workers

    # :reek:TooManyStatements
    def self.batch_test(files, opt)
      limit = [1, (Etc.nprocessors * 0.75).round].max
      queue = Thread::Queue.new
      prioritized_files(files).each { queue << it }
      queue.close
      failed = run_workers(limit, queue, opt)
      return if failed.empty?

      msg = failed.size == 1 ? failed.first : "\n#{failed.join("\n")}"
      raise "failed: #{msg}"
    end
    private_class_method :batch_test

    # :reek:TooManyStatements
    def self.matched_files(filematch)
      files = test_files
      return files unless filematch

      files.select! { it.match?(filematch) }
      raise "No tests matched: #{filematch}" if files.empty?

      files
    end
    private_class_method :matched_files

    def self.sequential_test(files, opt)
      files.each do |tf|
        puts "#{tf}: ".blue
        raise "failed: #{tf}" unless system(tf, *opt)
      end
    end
    private_class_method :sequential_test

    # :reek:BooleanParameter :reek:ControlParameter
    # :reek:LongParameterList
    def self.test!(filematch = nil, methodmatch = nil,
                   batch: false, list: false, quiet: false)
      files = matched_files(filematch)
      return puts files if list

      opt = options(methodmatch, quiet)
      batch ? batch_test(files, opt) : sequential_test(files, opt)
    end
  end
end
