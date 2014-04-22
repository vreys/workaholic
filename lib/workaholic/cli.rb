require 'singleton'

require 'workaholic/options_parser'
require 'workaholic/launcher'
require 'workaholic/signal_handler'

module Workaholic
  class CLI
    include Singleton

    attr_reader :options

    def setup(exec_name, args)
      @options = OptionsParser.parse(exec_name, args)
    end

    def run(worker_klass)
      launcher       = Launcher.new(worker_klass, options)
      signal_handler = SignalHandler.new(launcher)

      signal_handler.setup_trap

      Logging.logger.info("Starting processing, hit Ctrl-C to stop")

      begin
        launcher.run
        signal_handler.run
      rescue Interrupt
        launcher.stop
        exit(0)
      end
    end
  end
end