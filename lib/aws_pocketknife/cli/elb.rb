require "thor"
require "aws_pocketknife"

module AwsPocketknife
  module Cli
    class Elb < Thor

      desc "desc ELB_NAME", "describe elastic load balancer"
      def desc(elb_name)
        elb = AwsPocketknife::Elb.describe_elb_by_name(name: elb_name)
        if elb.nil?
          puts "ELB #{elb_name} not found"
        else
          AwsPocketknife::Ec2.nice_print(object: elb.to_h)
        end
      end

    end
  end
end