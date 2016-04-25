require 'aws_pocketknife'
require_relative "common/utils"


module AwsPocketknife
  module Route53

    @client = AwsPocketknife.elastic_beanstalk_client

    class << self
      include AwsPocketknife::Common::Utils

      
      def describe_environment_resources(environment_name: '')

        resp = client.describe_environment_resources({
             environment_name: environment_name,
         })

      end

    end

  end
end
