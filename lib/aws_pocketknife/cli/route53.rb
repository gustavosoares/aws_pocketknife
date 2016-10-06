require "thor"
require "aws_pocketknife"

module AwsPocketknife
  module Cli
    class Route53 < Thor

      desc "describe_hosted_zone HOSTED_ZONE", "describe hosted zone"
      def describe_hosted_zone(hosted_zone)
        hosted_zone = AwsPocketknife::Route53.describe_hosted_zone(hosted_zone: hosted_zone)
        unless hosted_zone.nil?
          AwsPocketknife::Route53.nice_print(object: hosted_zone.to_h)
        else
          puts "#{hosted_zone} not found"
        end
      end

      desc "list", "list hosted zones"
      def list
        hosted_zones = AwsPocketknife::Route53.list_hosted_zones
        headers = [ 'Name', 'Zone ID', 'Comment']
        data = []
        hosted_zones.each do |h|
          data << [h.name,
                   AwsPocketknife::Route53.get_hosted_zone_id(hosted_zone: h.id),
                   h.config.comment]
        end
        AwsPocketknife::Route53.pretty_table(headers: headers, data: data)
      end

      desc "list_records HOSTED_ZONE", "list records for hosted zone"
      def list_records(hosted_zone)
        records = AwsPocketknife::Route53.list_records_for_zone_name(hosted_zone_name: hosted_zone)
        headers = ["Name", "Type", "DNS Name"]
        data = []
        if records.length > 0
          records.each do |record|
            if record.type == 'CNAME'
              data << [record.name, record.type, record.resource_records[0].value]
            else
              if record.alias_target.nil?
                data << [record.name, record.type, "N/A"]
              else
                data << [record.name, record.type, record.alias_target.dns_name]
              end
            end
          end
          AwsPocketknife::Route53.pretty_table(headers: headers, data: data)
        else
          puts "No records found hosted zone #{hosted_zone}"
        end
      end

      desc "get_record HOSTED_ZONE RECORD_NAME --record_type", "Get record for hosted zone."
      #option :record_type, :type => :string, :default => 'A', :desc => 'Record type accepts SOA, A, TXT, NS, CNAME, MX, PTR, SRV, SPF, AAAA. Default to A'
      def get_record(hosted_zone, record_name, record_type='A')

        #record_type = options.fetch("record_type", 'A')
        records = AwsPocketknife::Route53.get_record(hosted_zone_name: hosted_zone,
                                                     record_name:record_name,
                                                     record_type: record_type)
        headers = ["Name", "Type", "DNS Name"]
        data = []
        if records.length > 0
          records.each do |record|
            if record.type == 'CNAME'
              data << [record.name, record.type, record.resource_records[0].value]
            else
              data << [record.name, record.type, record.alias_target.dns_name]
            end
          end
          AwsPocketknife::Route53.pretty_table(headers: headers, data: data)
        else
          puts "Record #{record_name} not found in hosted zone #{hosted_zone}"
        end
      end

      desc "update_record HOSTED_ZONE ORIGIN_DNS_NAME DESTINY_RECORD_NAME DESTINY_HOSTED_ZONE RECORD_TYPE (default to A)", "Update a dns record from an existing dns entry."
      def update_record(hosted_zone, origin_dns_name, destiny_record_name, destiny_hosted_zone, record_type='A')

        AwsPocketknife::Route53.update_record(origin_hosted_zone: hosted_zone,
                                              origin_dns_name: origin_dns_name,
                                              record_type: record_type,
                                              destiny_dns_name: destiny_record_name,
                                              destiny_hosted_zone: destiny_hosted_zone
        )

      end

    end
  end
end