require 'aws_pocketknife'
require 'base64'
require 'openssl'
require_relative "common/utils"

module AwsPocketknife
  module Asg

    @asg_client = AwsPocketknife.asg_client

    class << self
      include AwsPocketknife::Common::Utils

      def describe_asg_by_name(name: "")
        asgs = []
        asg_list = name.split(";")
        resp = @asg_client.describe_auto_scaling_groups({
                                         auto_scaling_group_names: asg_list,
                               })
        resp.auto_scaling_groups.each do |asg|
          asgs << asg
        end
        asgs
      end

      def list(max_records: 100)
        asgs = []
        resp = @asg_client.describe_auto_scaling_groups({
                                max_records: max_records,
                            })
        # resp.auto_scaling_groups.each do |asg|
        #   asgs << asg
        # end
        asgs << resp.auto_scaling_groups
        next_token = resp.next_token
        while true
          break if next_token.nil? or next_token.length == 0
          resp = get_asgs(next_token: next_token, max_records: max_records)
          asgs << resp.auto_scaling_groups
          next_token = resp.next_token

        end

        asgs.flatten!

      end

      private

      def get_asgs(next_token: "", max_records: 100)

        resp = @asg_client.describe_auto_scaling_groups({
                                max_records: max_records,
                                next_token: next_token,
                            })

      end

    end

  end
end
