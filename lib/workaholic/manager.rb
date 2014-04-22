require 'workaholic/actor'
require 'workaholic/runner'

module Workaholic
  class Manager
    include Actor

    trap_exit :runner_died

    SPIN_TIME_FOR_GRACEFUL_SHUTDOWN = 1

    attr_reader :launcher, :worker_klass, :runners, :shutdown_timeout, :threads

    def initialize(worker_klass, options)
      @threads = {}
      @worker_klass = worker_klass
      @runners = options[:concurrency].times.to_a.map do
        r = Runner.new_link(current_actor, worker_klass)
        r.proxy_id = r.object_id
        r
      end
    end

    def logger
      Logging.logger
    end

    def start
      logger.info { "Starting #{runners.count} runners" }
      runners.each{|r| r.async.run }
    end

    def stop(options = {})
      @done = true

      shutdown = options[:shutdown]
      timeout  = options[:timeout] || 10

      logger.info { "Shutting down #{threads.size} runners" }
      threads.each{|proxy_id, r| r.terminate if r.alive? }

      return if clean_up_for_graceful_shutdown

      hard_shutdown_in(timeout)
    end

    def real_thread(proxy_id, thread)
      threads[proxy_id] = thread
    end

    def runner_done(runner)
      threads.delete(runner.object_id)

      runner.terminate if runner.alive?
      shutdown if threads.empty?
    end

    private

    def runner_died(runner, reason)
      threads.delete(runner.object_id)

      if reason
        logger.info{ "Runner is dead. #{reason.class.to_s}: #{reason.message}" }
        logger.info{ reason.backtrace.join("\n") }
      end

      if stopped?
        shutdown if threads.empty?
      else
        logger.info{ "Starting runner after failure" }
        r = Runner.new_link(current_actor, worker_klass)
        r.proxy_id = r.object_id
        r.async.run
      end
    end

    def clean_up_for_graceful_shutdown
      if threads.select{|p, t| t.alive?}.empty?
        shutdown
        return true
      end

      after(SPIN_TIME_FOR_GRACEFUL_SHUTDOWN) { clean_up_for_graceful_shutdown }
      false
    end

    def stopped?
      @done == true
    end

    def shutdown
      signal_shutdown
    end

    def hard_shutdown_in(timeout)
      after(timeout) do
        logger.warn{ "Terminating #{threads.size} busy runner threads" }

        threads.each do |proxy_id, t|
          if t.alive?
            t.raise Shutdown
          end
        end

        signal_shutdown
      end
    end

    def signal_shutdown
      after(0) { signal(:shutdown) }
    end
  end
end