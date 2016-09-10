require "pretty_table"
require "awesome_print"
require_relative "logging"

module AwsPocketknife
  module Common
    module Utils
      #include AwsPocketknife::Common::Logging

      def ec2_client
        @ec2_client ||= AwsPocketknife.ec2_client
      end

      def iam_client
        @iam_client ||= AwsPocketknife.iam_client
      end

      def route53_client
        @route53_client ||= AwsPocketknife.route53_client
      end

      def elb_client
        @elb_client ||= AwsPocketknife.elb_client
      end

      def asg_client
        @asg_client ||= AwsPocketknife.asg_client
      end

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