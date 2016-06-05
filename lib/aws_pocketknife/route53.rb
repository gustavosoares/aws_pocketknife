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

      def update_cname_record(origin_hosted_zone: "",
                              origin_dns_name: "",
                              record_type: "CNAME",
                              destiny_dns_name:"",
                              destiny_hosted_zone: ""
      )

        hosted_zone_id, origin_record = get_hosted_zone_id_and_origin_record(origin_dns_name, origin_hosted_zone, record_type)

        new_dns_name = destiny_dns_name
        origin_record = origin_record[0]

        if not origin_record.alias_target.nil? and new_dns_name == origin_record.alias_target.dns_name
          puts "Origin and destiny alias_target.dns_name are the same: #{new_dns_name} Aborting..."
          return false
        elsif origin_record.resource_records.length != 0 and new_dns_name == origin_record.resource_records[0].value
          puts "Origin and destiny alias_target.dns_name are the same: #{new_dns_name} Aborting..."
          return false
        end

        update_or_create_record_with_cname(new_dns_name, origin_dns_name, record_type, hosted_zone_id)

      end

      def update_record_from_existing_dns_entry(origin_hosted_zone: "",
                        origin_dns_name: "",
                        record_type: "A",
                        destiny_dns_name:"",
                        destiny_hosted_zone: ""
      )

        # get hosted zone
        hosted_zone_id, origin_record = get_hosted_zone_id_and_origin_record(origin_dns_name, origin_hosted_zone, record_type)


        # get record for new dns name
        destiny_record = get_record(hosted_zone_name: destiny_hosted_zone,
                                    record_name: destiny_dns_name,
                                    record_type: record_type)

        if destiny_record.length == 0
          puts "Could not find destiny record for #{destiny_dns_name} at #{destiny_hosted_zone}"
          return nil
        end

        if destiny_record[0].alias_target.nil?
          puts "DNS #{destiny_dns_name} is invalid"
          return nil
        end

        destiny_hosted_zone_id = destiny_record[0].alias_target.hosted_zone_id
        new_dns_name = destiny_record[0].alias_target.dns_name
        origin_record = origin_record[0]

        if not origin_record.alias_target.nil? and new_dns_name == origin_record.alias_target.dns_name
          puts "Origin and destiny alias_target.dns_name are the same: #{new_dns_name} Aborting..."
          return false
        elsif origin_record.resource_records.length != 0 and new_dns_name == origin_record.resource_records[0].value
          puts "Origin and destiny alias_target.dns_name are the same: #{new_dns_name} Aborting..."
          return false
        end

        update_or_create_record_with_alias_record(destiny_hosted_zone_id, new_dns_name, origin_dns_name, record_type, hosted_zone_id)

      end

      def get_hosted_zone_id_and_origin_record(origin_dns_name, origin_hosted_zone, record_type)
        hosted_zone = describe_hosted_zone(hosted_zone: origin_hosted_zone)
        hosted_zone_id = get_hosted_zone_id(hosted_zone: hosted_zone.id)

        # get origin record
        origin_record = get_record(hosted_zone_name: origin_hosted_zone,
                                   record_name: origin_dns_name,
                                   record_type: record_type)

        if origin_record.length == 0
          puts "Could not find record for #{origin_dns_name} at #{origin_hosted_zone}"
        end
        return hosted_zone_id, origin_record
      end


      def update_record(origin_hosted_zone: "",
                        origin_dns_name: "",
                        record_type: "A",
                        destiny_dns_name:"",
                        destiny_hosted_zone: ""
      )


        if destiny_hosted_zone.empty?
          return update_cname_record(origin_hosted_zone: origin_hosted_zone,
                        origin_dns_name: origin_dns_name,
                        destiny_dns_name:destiny_dns_name,
                        destiny_hosted_zone: destiny_hosted_zone
          )
        else
          return update_record_from_existing_dns_entry(origin_hosted_zone: origin_hosted_zone,
                                                       origin_dns_name: origin_dns_name,
                                                       record_type: record_type,
                                                       destiny_dns_name:destiny_dns_name,
                                                       destiny_hosted_zone: destiny_hosted_zone
          )
        end


      end

      def update_or_create_record_with_cname(new_dns_name, origin_dns_name, record_type, hosted_zone_id)
        change = {
            action: "UPSERT",
            resource_record_set: {
                name: origin_dns_name,
                type: record_type,
                ttl: 300,
                resource_records: [{value: new_dns_name}]
            }
        }

        payload = get_payload_for_record_update(change: change, hosted_zone_id: hosted_zone_id)

        nice_print(object: payload)
        result = @client.change_resource_record_sets(payload)
      end

      def update_or_create_record_with_alias_record(destiny_hosted_zone_id, new_dns_name, origin_dns_name, record_type, hosted_zone_id)
        change = {
            action: "UPSERT",
            resource_record_set: {
                name: origin_dns_name,
                type: record_type,
                alias_target: {
                    hosted_zone_id: destiny_hosted_zone_id, # required
                    dns_name: new_dns_name, # required
                    evaluate_target_health: false, # required
                }
            }
        }

        payload = get_payload_for_record_update(change: change, hosted_zone_id: hosted_zone_id)

        nice_print(object: payload)
        result = @client.change_resource_record_sets(payload)
      end

      def get_payload_for_record_update(change: "", hosted_zone_id: "")

        payload = {
            hosted_zone_id: hosted_zone_id,
            change_batch: {
                comment: "",
                changes: [change]
            }

        }
      end

      def get_record(hosted_zone_name: "", record_name: "", record_type: "")
        record = []
        records = list_records_for_zone_name(
            hosted_zone_name: hosted_zone_name,
            record_name:record_name,
            record_type: record_type)

        records.each do |r|
          return [r] if r.name == record_name
        end

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