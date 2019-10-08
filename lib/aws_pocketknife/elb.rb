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

      def list(max_records: 100)
        elbs = []
        resp = elb_client.describe_load_balancers({
          page_size: max_records,
        })

        elbs << resp.load_balancer_descriptions
        next_marker = resp.next_marker
        while true
          break if next_marker.nil? or next_marker.empty?
          resp = get_elbs(next_marker: next_marker, max_records: max_records)
          elbs << resp.load_balancer_descriptions
          next_marker = resp.next_marker
        end

        elbs.flatten!

      end

      private

      def get_elbs(next_marker: "", max_records: 100)
        elb_client.describe_load_balancers({
                                page_size: max_records,
                                next_marker: next_token,
                            })

      end

    end

  end
end
