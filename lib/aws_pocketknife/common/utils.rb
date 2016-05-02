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

      def get_tag_value(tags: [], tag_key: "")
        unless tags.empty? or tag_key.length == 0
          tag =  tags.select { |tag| tag.key == tag_key }
          return tag[0].value if tag.length == 1
          return "" if tag.length == 0
        else
          return ""
        end
      end

    end
  end
end