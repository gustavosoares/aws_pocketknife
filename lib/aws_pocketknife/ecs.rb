require 'aws_pocketknife'
require 'base64'
require 'openssl'
require 'retryable'
require 'recursive-open-struct'

module AwsPocketknife
  module Ecs

    MAX_ATTEMPTS = 15
    DELAY_SECONDS = 10

    STATE_PENDING = 'pending'
    STATE_AVAILABLE = 'available'
    STATE_DEREGISTERED = 'deregistered'
    STATE_INVALID = 'invalid'
    STATE_FAILED = 'failed'
    STATE_ERROR = 'error'

    class << self
      include AwsPocketknife::Common::Utils
      #include AwsPocketknife::Common::Logging

      Logging = Common::Logging.logger

      def describe_clusters(name: '')
        ecs_client.describe_clusters({dry_run: false,
                                    clusters: [
                                      "", 
                                    ], 
                                    })
      end

      def list_clusters(max_results: 50)
        clusters = ecs_client.list_clusters({max_results: max_results,}).cluster_arns

        puts clusters

        return clusters
      end


    end

  end
end
