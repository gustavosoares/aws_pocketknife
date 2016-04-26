require 'aws_pocketknife'
require_relative "common/utils"


module AwsPocketknife
  module ElasticBeanstalk

    @client = AwsPocketknife.elastic_beanstalk_client

    class << self
      include AwsPocketknife::Common::Utils


      def describe_environment_resources(environment_name: '')

        resp = @client.describe_environment_resources({
             environment_name: environment_name,
         })

      end

      def list_environments()
        describe_environment
      end

      def describe_environment(environment_name: '')
        resp = nil
        if environment_name.length == 0
          resp = @client.describe_environments({})
        else
          resp = @client.describe_environments({
              environment_name: environment_name,
          })
        end

        resp[:environments]
      end

      def list_environment_variables(environment_name: '')

        #get application name
        environment = describe_environment(environment_name: environment_name)[0]
        app_name = environment.application_name

        #get environment_variables
        resp = @client.describe_configuration_settings({
               application_name: app_name,
               environment_name: environment,
           })

        configuration_setting = resp.configuration_settings[0]
        option_settings = configuration_setting.option_settings
        environment_variables = []
        option_settings.each do |option|
          if option.option_name == "EnvironmentVariables"
            environment_variables = option.value.split(",")
            break
          end
        end

        environment_variables

      end

    end

  end
end
