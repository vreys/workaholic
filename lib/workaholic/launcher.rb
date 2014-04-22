require 'actor'
require 'manager'

module Workaholic
  class Launcher
    include Actor

    trap_exit :actor_died

    attr_reader :done, :options, :manager

    def initialize(worker_klass, options)
      @done    = false
      @options = options
      @manager = Manager.new_link(worker_klass, options)
    end

    def run
      manager.async.start
    end

    def stop
      @done = true
      manager.stop(shutdown: true, timeout: options[:timeout])
      manager.wait(:shutdown)
    end

    private

    def actor_died(actor, reason)
      return if @done
      Logging.logger.warn("Workaholic died due to the following error, cannot recover, process exiting")
      handle_exception(reason)
      exit(1)
    end
  end
end