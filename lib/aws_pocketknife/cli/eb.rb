require "thor"
require "aws_pocketknife"

module AwsPocketknife
  module Cli
    class Eb < Thor

      desc "list", "list environments"
      def list
        environments = AwsPocketknife::ElasticBeanstalk.describe_environment
        headers = [ 'App Name', 'Env Name', 'cname', 'Updated', 'Version', 'Health']
        data = []
        environments.each do |e|
          data << [e.application_name, e.environment_name, e.cname, e.date_updated, e.version_label, e.health]
        end
        AwsPocketknife::ElasticBeanstalk.pretty_table(headers: headers, data: data)
      end

      desc "desc ENVIRONMENT_NAME", "describe environment name"
      def desc(environment_name)
        environment = AwsPocketknife::ElasticBeanstalk.describe_environment_resources(environment_name: environment_name)
        unless environment.nil?
          AwsPocketknife::ElasticBeanstalk.nice_print(object: environment.to_h)
        else
          puts "#{environment_name} not found"
        end
      end

      desc "vars NAME", "list environment variables for the specified elastic beanstalk environment name"
      def vars(environment_name)
        variables = AwsPocketknife::ElasticBeanstalk.list_environment_variables(environment_name: environment_name)
        headers = [ 'Name', 'Value']
        data = []
        variables.each do |v|
          v_temp = v.split("=")
          name = v_temp[0]

          # remove first element (headers) from array
          v_temp.shift
          value = v_temp.join
          data << [name, value]
        end
        puts "Environment: #{environment_name}"
        AwsPocketknife::ElasticBeanstalk.pretty_table(headers: headers, data: data)
      end

    end
  end
end