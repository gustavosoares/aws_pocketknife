require "thor"
require "aws_pocketknife"

module AwsPocketknife
  module Cli
    class Rds < Thor

      desc "snapshot SUBCOMMAND ...ARGS", "snapshot command lines"
      subcommand "snapshot", AwsPocketknife::Cli::RdsSnapshot

    end
  end
end