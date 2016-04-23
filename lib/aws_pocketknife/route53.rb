require 'aws_pocketknife'
require_relative "common/utils"


module AwsPocketknife
  module Route53

    @client = AwsPocketknife.route53_client

    class << self
      include AwsPocketknife::Common::Utils

      def list_hosted_zones
        result = @client.list_hosted_zones
        unless result.nil?
         return result.hosted_zones
        else
          return []
        end
      end


      def describe_hosted_zone(hosted_zone: "")

        hosted_zones = list_hosted_zones
        zone = find_hosted_zone_id(list: hosted_zones, name: hosted_zone)

        unless zone.nil?
          nice_print(object: zone.to_h)
        else
          puts "#{hosted_zone} not found"
        end
      end

      def get_hosted_zone_id(hosted_zone: "")
        hosted_zone.split("/").reverse[0]
      end

      private

      def find_hosted_zone_id(list: nil, name: nil)
        list.each do |h|
            return h if h.name == name
        end
        return nil
      end
    end

  end
end