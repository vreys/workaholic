module Workaholic
  class SignalHandler
    SUPPORTED_SIGNALS = %w(INT TERM USR1)

    attr_reader :launcher, :self_read, :self_write

    def initialize(launcher)
      @launcher = launcher
      @self_read, @self_write = IO.pipe
    end

    def setup_trap
      SUPPORTED_SIGNALS.each do |sig|
        begin
          trap sig do
            self_write.puts(sig)
          end
        rescue ArgumentError
          puts "Signal #{sig} not supported"
        end
      end
    end

    def run
      while readable_io = IO.select([self_read])
        signal = readable_io.first[0].gets.strip
        handle_signal(signal)
      end
    end

    private

    def handle_signal(signal)
      Logging.logger.info { "Got signal #{signal}" }
      send("handle_#{signal.downcase}!".to_sym)
    end

    def interrupt!
      raise Interrupt
    end

    alias :handle_int! :interrupt!
    alias :handle_term! :interrupt!

    def handle_usr1!
      launcher.manager.async.stop
    end
  end
end