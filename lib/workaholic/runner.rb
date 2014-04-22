require 'actor'
require 'shutdown'

module Workaholic
  class Runner
    include Actor

    attr_accessor :proxy_id
    attr_reader :boss, :worker

    def initialize(boss, worker_klass)
      @boss   = boss
      @worker = worker_klass.new
    end

    def run
      begin
        boss.async.real_thread(proxy_id, Thread.current)
        worker.work
      rescue Shutdown
      end

      boss.async.runner_done(current_actor)
    end
  end
end