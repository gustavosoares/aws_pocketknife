require "aws_pocketknife/version"
require 'aws-sdk-core'

module AwsPocketknife
  extend self

  class << self

    COMMON_OPTIONS = { retry_limit: 5 }

    def cf_client
      @cloud_formation_client ||= Aws::CloudFormation::Client.new(COMMON_OPTIONS)
    end

    def s3_client
      @s3_client ||= Aws::S3::Client.new(COMMON_OPTIONS)
    end

    def elb_client
      @elb_client ||= Aws::ElasticLoadBalancing::Client.new(COMMON_OPTIONS)
    end

    def auto_scaling_client
      @auto_scaling_client ||= Aws::AutoScaling::Client.new(COMMON_OPTIONS)
    end

    def elastic_beanstalk_client
      @elastic_beanstalk_client ||= Aws::ElasticBeanstalk::Client.new(COMMON_OPTIONS)
    end

    def iam_client
      @iam_client ||= Aws::IAM::Client.new(COMMON_OPTIONS)
    end

    def rds_client
      @rds_client ||= Aws::RDS::Client.new(COMMON_OPTIONS)
    end

    def ec2_client
      @ec2_client ||= Aws::EC2::Client.new(COMMON_OPTIONS)
    end

    def route53_client
      @route53_client ||= Aws::Route53::Client.new(COMMON_OPTIONS)
    end

  end
end


