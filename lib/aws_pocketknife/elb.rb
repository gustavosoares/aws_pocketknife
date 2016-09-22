require 'aws_pocketknife'

module AwsPocketknife
  module Elb

    class << self
      include AwsPocketknife::Common::Utils

      def describe_elb_by_name(name: '')
        resp = elb_client.describe_load_balancers({
                                                  load_balancer_names: [name],
                                                  page_size: 1,
                                              })

        if resp.nil? or resp.load_balancer_descriptions.empty?
          return nil
        else
          return resp.load_balancer_descriptions.first
        end
      end

    end

  end
end
