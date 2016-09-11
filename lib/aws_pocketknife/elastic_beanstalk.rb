require 'aws_pocketknife'

module AwsPocketknife
  module ElasticBeanstalk

    class << self
      include AwsPocketknife::Common::Utils

      def describe_environment_resources(environment_name: '')
        elastic_beanstalk_client.describe_environment_resources({
             environment_name: environment_name,
         })
      end

      def list_environments()
        describe_environment
      end

      def describe_environment(environment_name: '')
        resp = nil
        if environment_name.length == 0
          resp = elastic_beanstalk_client.describe_environments({})
        else
          environment_list = environment_name.split(";")
          resp = elastic_beanstalk_client.describe_environments({
                                                   environment_names: environment_list,
          })
        end

        resp[:environments]
      end

      def list_environment_variables(environment_name: '')

        #get application name
        environment = describe_environment(environment_name: environment_name)[0]
        app_name = environment.application_name

        #get environment_variables
        resp = elastic_beanstalk_client.describe_configuration_settings({
               application_name: app_name,
               environment_name: environment_name,
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
