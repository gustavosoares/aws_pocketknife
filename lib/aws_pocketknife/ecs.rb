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
        ecs_client.describe_clusters({clusters: [name]}).clusters.first
      end

      def list_clusters(max_results: 50)
        clusters_list = []
        clusters = ecs_client.list_clusters({max_results: max_results,}).cluster_arns
        clusters.each do |cluster|
          cluster_map = {}
          cluster_map[:name] = cluster.split('/')[1]
          info = describe_clusters name: cluster
          cluster_map[:info] = info
          clusters_list << cluster_map
        end
        return clusters_list
      end

      def describe_services(name: '', cluster: '')
        ecs_client.describe_services({cluster: cluster, services: [name]}).services.first
      end
        
      def list_services(cluster: '', max_results: 50)
        services_list = []
        services = ecs_client.list_services({max_results: max_results,
                                            cluster: cluster,
                              }).service_arns
        services.each do |service|
          service_map = {}
          service_map[:name] = service.split('/')[1]
          info = describe_services name: service, cluster: cluster
          service_map[:info] = info
          services_list << service_map          
        end
        return services_list
      end
    end

  end
end
