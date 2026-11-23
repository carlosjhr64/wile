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
end
