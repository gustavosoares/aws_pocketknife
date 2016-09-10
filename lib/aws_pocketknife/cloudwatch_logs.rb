require 'aws_pocketknife'
require 'base64'
require 'openssl'
require 'recursive-open-struct'
require_relative "common/utils"

module AwsPocketknife
  module CloudwatchLogs

    class << self
      include AwsPocketknife::Common::Utils

      def create_log_group(log_group_name: "")

        unless log_group_name.empty?
          cloudwatch_logs_client.create_log_group({
               log_group_name: log_group_name, # required
           })
        end

      end

    end

  end
end
