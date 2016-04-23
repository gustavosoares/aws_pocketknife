require_relative "../route53"

namespace :route53 do

  desc "describe hosted zone"
  task :describe_hosted_zone, [:hosted_zone] do |t, args|
    hosted_zone = AwsPocketknife::Route53.describe_hosted_zone(hosted_zone: args[:hosted_zone])
    unless hosted_zone.nil?
      AwsPocketknife::Route53.nice_print(object: hosted_zone.to_h)
    else
      puts "#{args[:hosted_zone]} not found"
    end
  end

  desc "listed hosted zones"
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

  desc "list records for hosted zone"
  task :list_records, [:hosted_zone] do |t, args|
    records = AwsPocketknife::Route53.list_records_for_zone_name(hosted_zone_name: args[:hosted_zone])
    headers = ["Name", "Type", "DNS Name", "Target Hosted zone id"]
    data = []
    if records.length > 0
      records.each do |record|
        if record.alias_target.nil?
          data << [record.name, record.type, nil, nil]
        else
          data << [record.name, record.type, record.alias_target.dns_name, record.alias_target.hosted_zone_id]
        end
      end
      AwsPocketknife::Route53.pretty_table(headers: headers, data: data)
    else
      puts "No records found hosted zone #{args[:hosted_zone]}"
    end
  end

end

