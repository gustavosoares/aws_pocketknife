require 'log4r'
include Log4r

Log4r::Logger.root.level = Log4r::INFO

module AwsPocketknife
  module Common
    module Logging
      class << self
        def get_log(name: "aws_pocketknife", pattern: "[%l] %d %m")

          log = Log4r::Logger.new(name)

          log_format = PatternFormatter.new(:pattern => pattern)
          log_output = Log4r::StdoutOutputter.new 'console'
          log_output.formatter = log_format

          log.add(log_output)

          return log
        end
      end
    end
  end
end