require "aws_pocketknife/version"
require 'aws-sdk-core'

module AwsPocketknife
  extend self

  AWS_REGION = ENV['AWS_REGION'] || 'ap-southeast-2'
  AWS_PROFILE = ENV['AWS_PROFILE'] || nil

  class << self

    def cf_client
      @cloud_formation_client ||= Aws::CloudFormation::Client.new(get_client_options)
    end

    def s3_client
      @s3_client ||= Aws::S3::Client.new(get_client_options)
    end

    def elb_client
      @elb_client ||= Aws::ElasticLoadBalancing::Client.new(get_client_options)
    end

    def auto_scaling_client
      @auto_scaling_client ||= Aws::AutoScaling::Client.new(get_client_options)
    end

    def elastic_beanstalk_client
      @elastic_beanstalk_client ||= Aws::ElasticBeanstalk::Client.new(get_client_options)
    end

    def iam_client
      @iam_client ||= Aws::IAM::Client.new(get_client_options)
    end

    def rds_client
      @rds_client ||= Aws::RDS::Client.new(get_client_options)
    end

    def ec2_client
      @ec2_client ||= Aws::EC2::Client.new(get_client_options)
    end

    def route53_client
      @route53_client ||= Aws::Route53::Client.new(get_client_options)
    end

    private

    def get_client_options
      if AWS_PROFILE.nil?
        return { retry_limit: 5, region: AWS_REGION }
      else
        credentials = Aws::SharedCredentials.new(profile_name: AWS_PROFILE)
        return { retry_limit: 5, region: AWS_REGION, credentials: credentials }
      end
    end
  end
end


