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
    end
  end
end