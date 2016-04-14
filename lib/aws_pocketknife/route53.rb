require 'aws_pocketknife'

module AwsPocketknife
  module Route53

    @client = AwsPocketknife.route53_client

    class << self

      def list_hosted_zones
        result = @client.list_hosted_zones
        result.hosted_zones
      end


      def describe_hosted_zone(hosted_zone)

        hosted_zones = list_hosted_zones
        zone = find_hosted_zone_id(list: hosted_zones, name: hosted_zone)

        unless zone.nil?
          puts "#{zone.name} | #{zone.id}"
        else
          puts "#{hosted_zone} not found"
        end
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