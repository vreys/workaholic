require 'optparse'

module Workaholic
  class OptionsParser
    def self.defaults
      {
        concurrency: 25,
        timeout:     10
      }
    end

    def self.parse(exec_name, inputs)
      options = {}

      parser = OptionParser.new do |o|
        o.on '-c', '--concurrency INT', "Processor threads to use" do |arg|
          options[:concurrency] = Integer(arg)
        end

        o.on '-t', '--timeout INT', "Shutdown timeout" do |arg|
          options[:timeout] = Integer(arg)
        end

        o.on '-g', '--tag NUM', "Progess tag for procline" do |arg|
          options[:tag] = arg
        end
      end

      parser.parse(inputs)

      parser.banner = "#{exec_name} [options]"
      parser.on_tail "-h", "--help", "Show help" do
        puts parser
        die 1
      end

      defaults.merge(options)
    end
  end
end