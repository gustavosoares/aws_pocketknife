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

      def describe_container_instances(name: '', container: '')
        ecs_client.describe_container_instances({cluster: name, container_instances: [container]}).container_instances.first
      end

      # list container instances
      def list_container_instances(cluster: '', max_results: 50)
        containers_list = []
        responses = []

        containers = get_containers max_results: max_results
        responses << containers.container_instance_arns
        next_token = containers.next_token

        while true
          break if next_token.nil? or next_token.empty?
          resp = get_containers(cluster: cluster, next_token: next_token, max_results: max_results)
          responses << resp.container_instance_arns
          next_token = resp.next_token
        end

        responses.flatten!

        responses.each do |container|
          container_map = {}
          container_map[:name] = container.split('/')[1]
          info = describe_containers name: cluster, container: container
          container_map[:info] = info
          container_list << container_map
        end
        return container_list
      end

      # clusters

      def describe_clusters(name: '')
        ecs_client.describe_clusters({clusters: [name]}).clusters.first
      end

      def list_clusters(max_results: 50)
        clusters_list = []
        responses = []

        clusters = get_clusters max_results: max_results
        responses << clusters.cluster_arns
        next_token = clusters.next_token

        while true
          break if next_token.nil? or next_token.empty?
          resp = get_clusters(next_token: next_token, max_results: max_results)
          responses << resp.cluster_arns
          next_token = resp.next_token
        end

        responses.flatten!

        responses.each do |cluster|
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
        responses = []

        services = get_services max_results: max_results, cluster: cluster
        responses << services.service_arns
        next_token = services.next_token

        while true
          break if next_token.nil? or next_token.empty?
          resp = get_services(next_token: next_token, max_results: max_results, cluster: cluster)
          responses << resp.service_arns
          next_token = resp.next_token
        end

        responses.flatten!

        responses.each do |service|
          service_map = {}
          service_map[:name] = service.split('/')[1]
          info = describe_services name: service, cluster: cluster
          service_map[:info] = info
          services_list << service_map          
        end
        return services_list
      end

      def get_services(next_token: "", max_results: 100, cluster: '')
        ecs_client.list_services({
            max_results: max_results,
            cluster: cluster,
            next_token: next_token,
        })
      end

      def get_clusters(next_token: "", max_results: 100)
        ecs_client.list_clusters({
            max_results: max_results,
            next_token: next_token
        })
      end

      def get_containers(cluster: "", next_token: "", max_results: 100)
        ecs_client.list_container_instances({
            max_results: max_results,
            cluster: cluster,
            next_token: next_token
        })
      end

    end

  end
end
