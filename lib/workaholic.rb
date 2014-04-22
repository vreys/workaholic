require 'celluloid'
require 'workaholic/version'
require 'workaholic/logging'
require 'workaholic/cli'

Celluloid.logger = nil

module Workaholic
  def self.logger
    Logging.logger
  end
end