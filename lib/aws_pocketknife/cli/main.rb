require "thor"
require "aws_pocketknife"

module AwsPocketknife
  module Cli
    class Main < Thor

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

    end
  end
end