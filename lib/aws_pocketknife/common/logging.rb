require 'log4r'

module AwsPocketknife
  module Common
    module Logging

      include Log4r
      Logger = Log4r::Logger
      Log4r::Logger.root.level = Log4r::INFO

      class << self

        def logger
          @log ||= initialize_log
        end

        def initialize_log(name: "aws_pocketknife", pattern: "[%l] %d %m")
          log = Logger.new(name)

          log_format = Log4r::PatternFormatter.new(:pattern => pattern)
          log_output = Log4r::StdoutOutputter.new 'console'
          log_output.formatter = log_format
          log.add(log_output)

          return log
        end

      end
    end
  end
end