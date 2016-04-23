require "pretty_table"
require "awesome_print"


module AwsPocketknife
  module Common
    module Utils
      def pretty_table(headers: [], data: [])
        puts PrettyTable.new(data, headers).to_s
      end

      # https://github.com/michaeldv/awesome_print
      def nice_print(object: nil)
        ap object
      end
    end
  end
end