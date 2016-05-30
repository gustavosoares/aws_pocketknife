require 'aws_pocketknife'
require 'base64'
require 'openssl'
require 'recursive-open-struct'
require_relative "common/utils"

module AwsPocketknife
  module Elb

    MAX_ATTEMPTS = 15
    DELAY_SECONDS = 10

    @elb_client = AwsPocketknife.elb_client

    class << self
      include AwsPocketknife::Common::Utils

      def describe_elb_by_name(name: "")
        resp = @elb_client.describe_load_balancers({
                                                  load_balancer_names: [name],
                                                  page_size: 1,
                                              })

        if resp.nil? or resp.load_balancer_descriptions.length == 0
          return nil
        else
          return resp.load_balancer_descriptions.first
        end
      end

    end

  end
end
