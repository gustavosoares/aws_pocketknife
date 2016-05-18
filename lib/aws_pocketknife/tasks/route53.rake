require_relative "../route53"

namespace :route53 do

  desc "Describe hosted zone"
  task :describe_hosted_zone, [:hosted_zone] do |t, args|
    hosted_zone = AwsPocketknife::Route53.describe_hosted_zone(hosted_zone: args[:hosted_zone])
    unless hosted_zone.nil?
      AwsPocketknife::Route53.nice_print(object: hosted_zone.to_h)
    else
      puts "#{args[:hosted_zone]} not found"
    end
  end

  desc "Listed hosted zones"
  task :list_hosted_zones do
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

  desc "List records for hosted zone"
  task :list_records, [:hosted_zone] do |t, args|
    records = AwsPocketknife::Route53.list_records_for_zone_name(hosted_zone_name: args[:hosted_zone])
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
      puts "No records found hosted zone #{args[:hosted_zone]}"
    end
  end

  desc "Get record for hosted zone. Record type accepts SOA, A, TXT, NS, CNAME, MX, PTR, SRV, SPF, AAAA"
  task :get_record, [:hosted_zone, :record_name, :record_type] do |t, args|
    record_type = args[:record_type] || 'A'
    record_name = args[:record_name]
    records = AwsPocketknife::Route53.get_record(hosted_zone_name: args[:hosted_zone],
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
      puts "Record #{record_name} not found in hosted zone #{args[:hosted_zone]}"
    end
  end

  desc "Update dns record from existing dns entry."
  task :update_record, [:hosted_zone, :record_name, :destiny_record_name, :destiny_hosted_zone, :record_type] do |t, args|
    record_type = args[:record_type] || 'A'
    origin_dns_name = args[:record_name]
    destiny_record_name = args[:destiny_record_name]
    hosted_zone = args[:hosted_zone]
    destiny_hosted_zone = args[:destiny_hosted_zone]
    AwsPocketknife::Route53.update_record(origin_hosted_zone: hosted_zone,
                                          origin_dns_name: origin_dns_name,
                                          record_type: record_type,
                                          destiny_dns_name: destiny_record_name,
                                          destiny_hosted_zone: destiny_hosted_zone
    )

  end


end

