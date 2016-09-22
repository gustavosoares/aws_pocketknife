require "thor"
require "aws_pocketknife"

module AwsPocketknife
  module Cli
    class Asg < Thor

      desc "list", "list all autoscaling groups"
      def list
        asgs = AwsPocketknife::Asg.list
        print_asg(asgs: asgs)
      end

      desc "desc ASG_NAME", "describe autoscaling group name"
      def desc(asg_name)
        asgs = AwsPocketknife::Asg.describe_asg_by_name(name: asg_name)
        print_asg(asgs: asgs)
      end

      private

      def print_asg(asgs: [])
        headers = ["name", "min size", "max size", "desired capacity", "instances", "elb"]
        data = []
        if asgs.length > 0
          asgs.each do |asg|
            instances = []
            asg.instances.map { |instance| instances << instance.instance_id }
            data << [asg.auto_scaling_group_name, asg.min_size, asg.max_size,
                     asg.desired_capacity, instances.join(", "), asg.load_balancer_names.join(", ")]
          end
          AwsPocketknife::Asg.pretty_table(headers: headers, data: data)
        else
          puts "No asg(s) found for name #{args[:name]}"
        end
      end

    end
  end
end