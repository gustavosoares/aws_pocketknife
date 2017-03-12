require "thor"
require "aws_pocketknife"

module AwsPocketknife
  module Cli
    class Ecs < Thor

      desc "list_clusters", "list clustes"
      def list_clusters()
        clusters = AwsPocketknife::Ecs.list_clusters
        headers = ["name", "status", "services", "containers_count","running_tasks_count", "pending_tasks_count",]
        data = []
        if clusters.nil?
          puts "No clusters found. Check your region"
        else
          #AwsPocketknife::Ecs.nice_print(object: clusters)
          clusters.each do |cluster|
            info = cluster[:info]
            data << [cluster[:name], info.status, info.active_services_count,
                    info.registered_container_instances_count, info.running_tasks_count, info.pending_tasks_count
            ]
          end
          AwsPocketknife::Ecs.pretty_table(headers: headers, data: data)

        end
      end

      desc "list_services CLUSTER_NAME", "list services for a given cluster"
      def list_services(cluster)
        services = AwsPocketknife::Ecs.list_services cluster: cluster
        headers = ["name", "status", "desired_count","running_count", 
        "pending_count", "task_definition", "maximum_percent", "minimum_healthy_percent"]
        data = []
        if services.nil?
          puts "No service found"
        else
          services.each do |service|
            info = service[:info]
            data << [service[:name], info.status, info.desired_count,
                    info.running_count, info.pending_count, info.task_definition.split('/')[1],
                    info.deployment_configuration.maximum_percent, info.deployment_configuration.minimum_healthy_percent
            ]
          end
          AwsPocketknife::Ecs.pretty_table(headers: headers, data: data)
        end
      end

      desc "list_instances for CLUSTER_NAME", "list instances for a given cluster"
      def list_instances(cluster)
        instances = AwsPocketknife::Ecs.list_container_instances cluster: cluster
        headers = ["name", "ec2_instance_id", "pending_tasks_count","running_tasks_count", 
        "status"]
        data = []
        if instances.nil?
          puts "No instances found"
        else
          instances.each do |instance|
            info = instance[:info]
            data << [instance[:name], info.ec2_instance_id, info.pending_tasks_count,
                    info.running_tasks_count, info.status
            ]
          end
          AwsPocketknife::Ecs.pretty_table(headers: headers, data: data)
        end
      end      
    end
  end
end