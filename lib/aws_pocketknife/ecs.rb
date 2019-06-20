require 'aws_pocketknife'
require 'base64'
require 'openssl'
require 'retryable'
require 'date'
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

      Logging = Common::Logging.logger

      # container instance

      # set a list of instances to draining. instances is a comma delimited string

      def drain_instances(cluster: '', names: '')
        ecs_client.update_container_instances_state({
          cluster: cluster,
          container_instances: names.split(';'), # required
          status: "DRAINING", # required, accepts ACTIVE, DRAINING
        })
      end

      def describe_container_instances(cluster: '', container: '')
        ecs_client.describe_container_instances({cluster: cluster, container_instances: [container]}).container_instances.first
      end

      # list container instances
      def list_container_instances(cluster: '', max_results: 50)
        containers_list = []
        responses = []

        containers = get_containers cluster: cluster, max_results: max_results
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
          task_list = []
          container_map[:name] = container.split('/')[1]
          info = describe_container_instances cluster: cluster, container: container
          container_map[:info] = info
          #container_map[:tasks] = list_container_tasks(cluster: cluster, container_name: container_map[:name])
          containers_list << container_map
        end
        return containers_list
      end

      # list tasks in container instance
      def list_container_tasks(cluster: '', container_name: '')
        tasks_list = []
        tasks = list_tasks cluster: cluster, container_instance: container_name
        describe_tasks(cluster: cluster, tasks: tasks)
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

      # services 

      def describe_services(name: '', cluster: '')
        ecs_client.describe_services({cluster: cluster, services: [name]}).services.first
      end

      def create_service(payload: {})
        ecs_client.create_service(payload)
      end

      def clone_service(name: '', cluster: '')
        d = DateTime.now
        date_fmt = d.strftime("%d%m%Y_%H%M%S")
        current_service = describe_services name: name, cluster: cluster
        new_name = "#{name}-clone-#{date_fmt}"
        payload = {
          cluster: cluster,
          service_name: new_name,
          task_definition: current_service.task_definition,
          load_balancers: current_service.load_balancers.to_a,
          desired_count: current_service.desired_count,
          role: current_service.role_arn,
          deployment_configuration: current_service.deployment_configuration.to_h,
          placement_constraints: current_service.placement_constraints.to_a,
          placement_strategy: current_service.placement_strategy.to_a,
        }
        puts "Cloned service payload:"
        AwsPocketknife::Ecs.nice_print(object: payload.to_h)
        create_service payload: payload
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
          service_map[:task_definition] = describe_task_definition task_definition: info.task_definition
          services_list << service_map          
        end
        return services_list
      end

      # tasks-definitions

      def describe_task_definition(task_definition: '')
        resp = ecs_client.describe_task_definition({task_definition: task_definition})
        return resp.task_definition.container_definitions.first
      end

      def list_tasks cluster: '', container_instance: ''
        ecs_client.list_tasks({
          cluster: cluster, 
          container_instance: container_instance, 
        }).task_arns
      end

      def describe_tasks cluster: '', tasks: []
        if tasks.empty?
          return []
        else
          return ecs_client.describe_tasks({
            cluster: cluster,
            tasks: tasks, 
          })
        end
      end

      # helpers

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
