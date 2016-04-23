require "pretty_table"

module AwsPocketknife
  module Common
    module Utils
      def pretty_table(headers: [], data: [])
        puts PrettyTable.new(data, headers).to_s
      end
    end
  end
end