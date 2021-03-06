require "thor"
require "aws_pocketknife"

module AwsPocketknife
  module Cli
    class Main < Thor
      map %w[--version -v] => :__print_version

      desc "ec2 SUBCOMMAND ...ARGS", "ec2 command lines"
      subcommand "ec2", AwsPocketknife::Cli::Ec2

      desc "ami SUBCOMMAND ...ARGS", "ami command lines"
      subcommand "ami", AwsPocketknife::Cli::Ami

      desc "eb SUBCOMMAND ...ARGS", "elastic beanstalk command lines"
      subcommand "eb", AwsPocketknife::Cli::Eb

      desc "route53 SUBCOMMAND ...ARGS", "route53 command lines"
      subcommand "route53", AwsPocketknife::Cli::Route53

      desc "iam SUBCOMMAND ...ARGS", "iam command lines"
      subcommand "iam", AwsPocketknife::Cli::Iam

      desc "rds SUBCOMMAND ...ARGS", "rds command lines"
      subcommand "rds", AwsPocketknife::Cli::Rds

      desc "asg SUBCOMMAND ...ARGS", "asg command lines"
      subcommand "asg", AwsPocketknife::Cli::Asg

      desc "elb SUBCOMMAND ...ARGS", "elb command lines"
      subcommand "elb", AwsPocketknife::Cli::Elb

      desc "ecs SUBCOMMAND ...ARGS", "ecs command lines"
      subcommand "ecs", AwsPocketknife::Cli::Ecs

      desc "--version, -v", "print the version"
      def __print_version
        puts AwsPocketknife::VERSION
      end
    
    end
  end
end