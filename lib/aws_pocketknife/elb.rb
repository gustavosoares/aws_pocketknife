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

      def list_v2(max_records: 100)
        elbs = []
        resp = elb_clientV2.describe_load_balancers({
          page_size: max_records,
        })

        elbs << resp.load_balancers
        next_marker = resp.next_marker
        while true
          break if next_marker.nil? or next_marker.empty?
          resp = get_elbs(next_marker: next_marker, max_records: max_records)
          elbs << resp.load_balancers
          next_marker = resp.next_marker
        end

        elbs.flatten!

      end
      private

      def get_elbs(next_marker: "", max_records: 100)
        elb_client.describe_load_balancers({
                                page_size: max_records,
                                marker: next_marker,
                            })
      end

      def get_elbs_v2(next_marker: "", max_records: 100)
        elb_clientV2.describe_load_balancers({
                                page_size: max_records,
                                marker: next_marker,
                            })
      end
    end

  end
end
