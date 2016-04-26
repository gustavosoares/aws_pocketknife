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

    end

  end
end
