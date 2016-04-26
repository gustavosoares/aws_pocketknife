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
    headers = [ 'App Name', 'Env Name', 'cname', 'Updated', 'Version', 'Health']
    data = []
    environments.each do |e|
      data << [e.application_name, e.environment_name, e.cname, e.date_updated, e.version_label, e.health]
    end
    AwsPocketknife::ElasticBeanstalk.pretty_table(headers: headers, data: data)
  end

  desc "list environment variables for an environment"
  task :list_environment_variables, [:environment_name] do |t, args|
    variables = AwsPocketknife::ElasticBeanstalk.list_environment_variables(environment_name: args[:environment_name])
    headers = [ 'Name', 'Value']
    data = []
    variables.each do |v|
      v_temp = v.split("=")
      name = v_temp[0]

      # remove first element from array
      v_temp.shift
      value = v_temp.join
      data << [name, value]
    end
    puts "Environment variables for environment: #{args[:environment_name]}"
    AwsPocketknife::ElasticBeanstalk.pretty_table(headers: headers, data: data)
  end


end

