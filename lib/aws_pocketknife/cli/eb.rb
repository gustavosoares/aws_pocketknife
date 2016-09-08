require "thor"
require "aws_pocketknife"
require "aws_pocketknife/elastic_beanstalk"

module AwsPocketknife
  module Cli
    class Eb < Thor

      desc "list_env", "list_environments"
      def list_env
        environments = AwsPocketknife::ElasticBeanstalk.describe_environment
        headers = [ 'App Name', 'Env Name', 'cname', 'Updated', 'Version', 'Health']
        data = []
        environments.each do |e|
          data << [e.application_name, e.environment_name, e.cname, e.date_updated, e.version_label, e.health]
        end
        AwsPocketknife::ElasticBeanstalk.pretty_table(headers: headers, data: data)
      end

      desc "desc_env NAME", "describe environment name"
      def desc_env(environment_name)
        environment = AwsPocketknife::ElasticBeanstalk.describe_environment_resources(environment_name: environment_name)
        unless environment.nil?
          AwsPocketknife::ElasticBeanstalk.nice_print(object: environment.to_h)
        else
          puts "#{environment_name} not found"
        end
      end

      desc "list_env_variables NAME", "list environment variables for the environment name"
      def list_env_variables(environment_name)
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