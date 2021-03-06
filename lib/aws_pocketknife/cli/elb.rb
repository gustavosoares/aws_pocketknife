require "thor"
require "aws_pocketknife"

module AwsPocketknife
  module Cli
    class Elb < Thor

      desc "desc ELB_NAME", "describe classic elastic load balancer"
      def desc(elb_name)
        elb = AwsPocketknife::Elb.describe_elb_by_name(name: elb_name)
        if elb.nil?
          puts "ELB #{elb_name} not found"
        else
          AwsPocketknife::Ec2.nice_print(object: elb.to_h)
        end
      end

      desc "list", "list elastic load balancer"
      def list()
        elbs = AwsPocketknife::Elb.list
        print_elbs(elbs: elbs)
      end

      desc "list_v2", "list load balancers using v2 api (application and network loadbalancers)"
      def list_v2()
        elbs = AwsPocketknife::Elb.list_v2
        print_elbs_v2(elbs: elbs)
      end

      private

      def print_elbs(elbs: [])
        headers = ["name", "vpc_id", "security_groups", "scheme"]
        data = []
        if elbs.length > 0
          elbs.each do |elb|
            data << [elb.load_balancer_name, elb.vpc_id, elb.security_groups.join(", "), elb.scheme]
          end
          AwsPocketknife::Elb.pretty_table(headers: headers, data: data)
        else
          puts "No elb(s) found for name #{args[:name]}"
        end
      end

      def print_elbs_v2(elbs: [])
        headers = ["name", "vpc_id", "security_groups", "scheme", "type"]
        data = []
        if elbs.length > 0
          elbs.each do |elb|
            data << [elb.load_balancer_name, elb.vpc_id, elb.security_groups.join(", "), elb.scheme, elb.type]
          end
          AwsPocketknife::Elb.pretty_table(headers: headers, data: data)
        else
          puts "No elb(s) found for name #{args[:name]}"
        end
      end
    end
  end
end