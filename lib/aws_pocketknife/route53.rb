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
      end

      def update_record(hosted_zone_name: "", record_name: "", record_type: "A", new_dns_name:"")
        record_before_change = get_record(hosted_zone_name: record_name,
                                          record_name: record_name,
                                          record_type: record_type)

        if record_before_change.length == 0
          return nil
        end

        record = record_before_change[0]
        payload = {
            hosted_zone_id: hosted_zone_name,
            change_batch: {
                changes: [
                    {
                        action: "UPSERT",
                        resource_record_set: {
                            name: record_name,
                            type: record_type,
                            set_identifier: record.set_identifier,
                            resource_records: [
                                {
                                    value: "RData", # required
                                },
                            ],
                            alias_target: {
                                hosted_zone_id: "ResourceId", # required
                                dns_name: new_dns_name, # required
                                evaluate_target_health: false, # required
                            },
                        }
                    }
                ]
            }

        }

        result = @client.change_resource_record_sets(payload)

      end

      def get_record(hosted_zone_name: "", record_name: "", record_type: "")
        record = list_records_for_zone_name(
            hosted_zone_name: hosted_zone_name,
            record_name:record_name,
            record_type: record_type)

        return record
      end

      def list_records_for_zone_name(hosted_zone_name: "", record_name: "", record_type: "")
        records = []
        hosted_zone = describe_hosted_zone(hosted_zone: hosted_zone_name)
        return records if hosted_zone.nil?

        hosted_zone_id = get_hosted_zone_id(hosted_zone: hosted_zone.id)

        result = nil
        if record_name.length != 0 and record_type != 0
          result = @client.list_resource_record_sets({hosted_zone_id: hosted_zone_id,
                                                      start_record_name: record_name,
                                                      start_record_type: record_type, # accepts SOA, A, TXT, NS, CNAME, MX, PTR, SRV, SPF, AAAA
                                                      max_items: 1,
                                                     })
        else
          result = @client.list_resource_record_sets({hosted_zone_id: hosted_zone_id})
        end
        result.resource_record_sets.each do |record|
          if ["A", "CNAME", "AAAA"].include?record.type
            records << record
          end
        end
        return records
      end

      def get_hosted_zone_id(hosted_zone: "")
        hosted_zone.split("/").reverse[0]
      end

      private

      # Recevies a list of hosted zones and returns the element specified in name
      def find_hosted_zone_id(list: nil, name: nil)
        list.each do |h|
            return h if h.name == name
        end
        return nil
      end
    end

  end
end