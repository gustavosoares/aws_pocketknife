require "thor"
require "aws_pocketknife"
require_relative "ec2"

module AwsPocketknife
  module Cli
    class Main < Thor

      desc "ec2 SUBCOMMAND ...ARGS", "ec2 command lines"
      subcommand "ec2", AwsPocketknife::Cli::Ec2

    end
  end
end