require "thor"
require "aws_pocketknife"

module AwsPocketknife
  module Cli
    class Ecs < Thor

      desc "list_clusters", "list clustes"
      def list_clusters()
        clusters = AwsPocketknife::Ecs.list_clusters
        if clusters.nil?
          puts "No clusters found. Check your region"
        else
          AwsPocketknife::Ecs.nice_print(object: clusters)
        end
      end
    end
  end
end