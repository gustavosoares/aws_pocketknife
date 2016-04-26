require_relative "../elastic_beanstalk"

namespace :elasticbeanstalk do

  desc "describe_environment_resources"
  task :describe_environment_resources, [:environment_name] do |t, args|
    environment = AwsPocketknife::ElasticBeanstalk.describe_environment_resources(environment_name: args[:environment_name])
    unless environment.nil?
      AwsPocketknife::ElasticBeanstalk.nice_print(object: environment.to_h)
    else
      puts "#{args[:environment_name]} not found"
    end
  end

  desc "list environments"
  task :list_environments do
    environments = AwsPocketknife::ElasticBeanstalk.describe_environment
    headers = [ 'App Name', 'cname', 'Env Name', 'Updated', 'Version', 'Health']
    data = []
    environments.each do |e|
      data << [e.application_name, e.cname, e.environment_name, e.date_updated, e.version_label, e.health]
    end
    AwsPocketknife::ElasticBeanstalk.pretty_table(headers: headers, data: data)
  end

  #
  # desc "list records for hosted zone"
  # task :list_records, [:hosted_zone] do |t, args|
  #   records = AwsPocketknife::Route53.list_records_for_zone_name(hosted_zone_name: args[:hosted_zone])
  #   headers = ["Name", "Type", "DNS Name", "Target Hosted zone id"]
  #   data = []
  #   if records.length > 0
  #     records.each do |record|
  #       if record.alias_target.nil?
  #         data << [record.name, record.type, nil, nil]
  #       else
  #         data << [record.name, record.type, record.alias_target.dns_name, record.alias_target.hosted_zone_id]
  #       end
  #     end
  #     AwsPocketknife::Route53.pretty_table(headers: headers, data: data)
  #   else
  #     puts "No records found hosted zone #{args[:hosted_zone]}"
  #   end
  # end

end

