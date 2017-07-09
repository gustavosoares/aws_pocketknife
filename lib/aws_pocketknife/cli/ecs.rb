require "thor"
require "colorize"
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
        "pending_count", "task_definition", "maximum_percent", "minimum_healthy_percent", "cpu (units)", "mem (MiB)", "mem_reservation (MiB)"]
        data = []
        if services.nil?
          puts "No service found"
        else
          mem_total = 0
          mem_res_total = 0
          cpu_total = 0
          services.each do |service|
            info = service[:info]
            task_def = service[:task_definition]
            data << [service[:name], info.status, info.desired_count,
                    info.running_count, info.pending_count, info.task_definition.split('/')[1],
                    info.deployment_configuration.maximum_percent, info.deployment_configuration.minimum_healthy_percent,
                    task_def.cpu, task_def.memory, task_def.memory_reservation
            ]
            cpu_total = cpu_total + task_def.cpu unless task_def.cpu.nil?
            mem_total = mem_total + task_def.memory unless task_def.memory.nil?
            mem_res_total = (mem_res_total + task_def.memory_reservation) unless task_def.memory_reservation.nil?
          end
          puts ""
          puts "Memory is the hard limit (in MiB) of memory to present to the container. If your container attempts to exceed the memory specified here, the container is killed."
          puts "Memory reservation is the soft limit (in MiB) of memory to reserve for the container. When system memory is under contention, Docker attempts to keep the container memory to this soft limit"
          puts ""
          AwsPocketknife::Ecs.pretty_table(headers: headers, data: data)
          puts ""
          puts "CPU TOTAL: #{cpu_total} Units"
          puts "MEM TOTAL: #{mem_total} MiB"
          puts "MEM RES TOTAL: #{mem_res_total} MiB"
          puts ""
        end
      end

      desc "desc_service CLUSTER_NAME, SERVICE_NAME", "describe service for a given cluster"
      def desc_service(cluster, service_name)
        service = AwsPocketknife::Ecs.describe_services cluster: cluster, name: service_name
        if service.nil?
          puts "service #{service_name} not found"
        else
          AwsPocketknife::Ecs.nice_print(object: service.to_h)
        end
      end

      desc "clone_service CLUSTER_NAME, SERVICE_NAME", "creates a copy of an existing service"
      def clone_service(cluster, service_name)
        resp = AwsPocketknife::Ecs.clone_service cluster: cluster, name: service_name
        puts ""
        puts "Response: "
        puts ""
        AwsPocketknife::Ecs.nice_print(object: resp.to_h)
      end

      # container instance
      desc "drain_instances CLUSTER_NAME, CONTAINERS", "drains containers associated to the ecs cluster. CONTAINERS can a be a string delimited list"
      def drain_instances(cluster, names)
        resp = AwsPocketknife::Ecs.drain_instances cluster: cluster, names: names
        puts ""
        puts "Response: "
        puts ""
        AwsPocketknife::Ecs.nice_print(object: resp.to_a)
      end

      # container instance
      desc "list_instance_tasks CLUSTER_NAME, CONTAINER_NAME", "list tasks running in container (instance)"
      def list_instance_tasks(cluster, name)
        resp = AwsPocketknife::Ecs.list_container_tasks cluster: cluster, container_name: name
        headers = ["name", "started_at", "stopped_at", "last_status", "task"]
        data = []
        if resp.nil?
          puts "No tasks found"
        else
          resp.tasks.each do |task|
            data << [task.task_definition_arn.split('/')[1], task.started_at, task.stopped_at, task.last_status, task.task_arn.split('/')[1]]            
          end
          AwsPocketknife::Ecs.pretty_table(headers: headers, data: data)
        end
      end

      desc "list_instances CLUSTER_NAME", "list instances for a given cluster"
      def list_instances(cluster)
        instances = AwsPocketknife::Ecs.list_container_instances cluster: cluster
        headers = ["name", "ec2_instance_id", "agent_connected",
                  "pending_tasks_count","running_tasks_count", "status",
                  "cpu (units)", "mem (MiB)"
                ]
        headers_2 = ["total",
          "total pending", "total running",
          "cpu_reserved / cpu_total", "mem_reserved / mem_total"
        ]
        data = []
        data_2 = []
        if instances.nil?
          puts "No instances found"
        else
          count = 0
          mem_cluster_total = 0.0
          mem_cluster_res_total = 0.0
          mem_percentage = 0.0
          cpu_cluster_total = 0.0
          cpu_cluster_res_total = 0.0
          cpu_percentage = 0.0
          pending_tasks_count_total = 0
          running_tasks_count_total = 0
          instances.each do |instance|
            info = instance[:info]
            cpu_total = info.registered_resources[0].integer_value
            mem_total = info.registered_resources[1].integer_value
            cpu_available = info.remaining_resources[0].integer_value
            mem_available = info.remaining_resources[1].integer_value
            connected = info.agent_connected
            data << [instance[:name], info.ec2_instance_id, connected,
              info.pending_tasks_count, info.running_tasks_count, info.status,
              "#{cpu_available} / #{cpu_total}", "#{mem_available} / #{mem_total}"
            ]
            pending_tasks_count_total = pending_tasks_count_total + info.pending_tasks_count
            running_tasks_count_total = running_tasks_count_total + info.running_tasks_count
            mem_cluster_total = mem_cluster_total + mem_total
            mem_cluster_res_total = mem_cluster_res_total + mem_available
            mem_percentage = (((mem_cluster_total - mem_cluster_res_total)/mem_cluster_total) * 100).round(2)
            cpu_cluster_total = cpu_cluster_total + cpu_total
            cpu_cluster_res_total = cpu_cluster_res_total + cpu_available
            cpu_percentage = (((cpu_cluster_total - cpu_cluster_res_total)/cpu_cluster_total) * 100).round(2)
            count = count + 1
          end
            data_2 << [count,
              pending_tasks_count_total, running_tasks_count_total,
              "#{(cpu_cluster_total - cpu_cluster_res_total).round(0)} / #{cpu_cluster_total.round(0)} (#{cpu_percentage} %)", "#{(mem_cluster_total - mem_cluster_res_total).round(0)} / #{mem_cluster_total.round(0)} (#{mem_percentage} %)"
            ]
          AwsPocketknife::Ecs.pretty_table(headers: headers, data: data)
          puts ""
          puts ""
          AwsPocketknife::Ecs.pretty_table(headers: headers_2, data: data_2)
        end
      end
    end
  end
end