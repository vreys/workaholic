module Workaholic
  module Logging
    class Pretty < Logger::Formatter
      # Provide a call() method that returns the formatted message.
      def call(severity, time, program_name, message)
        "[#{time.utc.iso8601} #{Process.pid} TID-#{Thread.current.object_id.to_s(36)} #{severity}]: #{message}\n"
      end
    end

    def self.initialize_logger(log_target = STDOUT)
      oldlogger = @logger
      @logger = Logger.new(log_target)
      @logger.level = Logger::INFO
      @logger.formatter = Pretty.new
      oldlogger.close if oldlogger
      @logger
    end

    def self.logger
      @logger || initialize_logger
    end
  end
end