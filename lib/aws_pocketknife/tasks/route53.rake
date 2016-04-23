require_relative "../route53"

namespace :route53 do

  desc "describe hosted zone"
  task :describe_hosted_zone, [:hosted_zone] do |t, args|
    hosted_zone = AwsPocketknife::Route53.describe_hosted_zone(hosted_zone: args[:hosted_zone])
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

end

