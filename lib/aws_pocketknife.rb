require 'aws_pocketknife/version'
require 'aws-sdk-core'

require 'aws_pocketknife/common/utils'
require 'aws_pocketknife/common/logging'

require 'aws_pocketknife/iam'
require 'aws_pocketknife/ec2'
require 'aws_pocketknife/ecs'
require 'aws_pocketknife/route53'
require 'aws_pocketknife/asg'
require 'aws_pocketknife/cloudwatch_logs'
require 'aws_pocketknife/elastic_beanstalk'
require 'aws_pocketknife/elb'
require 'aws_pocketknife/rds'

require 'aws_pocketknife/cli/iam'
require 'aws_pocketknife/cli/asg'
require 'aws_pocketknife/cli/elb'
require 'aws_pocketknife/cli/ec2'
require 'aws_pocketknife/cli/ecs'
require 'aws_pocketknife/cli/ami'
require 'aws_pocketknife/cli/eb'
require 'aws_pocketknife/cli/route53'
require 'aws_pocketknife/cli/rds_snapshot'
require 'aws_pocketknife/cli/rds'
require 'aws_pocketknife/cli/main'

module AwsPocketknife
  extend self

  AWS_REGION = ENV['AWS_REGION'] || 'us-west-2'
  AWS_PROFILE = ENV['AWS_PROFILE'] || nil

  class << self

    def cloudwatch_logs_client
      @cloudwatch_logs_client ||= Aws::CloudWatchLogs::Client.new(get_client_options)
    end

    def cf_client
      @cloud_formation_client ||= Aws::CloudFormation::Client.new(get_client_options)
    end

    def s3_client
      @s3_client ||= Aws::S3::Client.new(get_client_options)
    end

    def elb_client
      @elb_client ||= Aws::ElasticLoadBalancing::Client.new(get_client_options)
    end

    def elb_clientV2
      @elb_clientV2 ||= Aws::ElasticLoadBalancingV2::Client.new(get_client_options)
    end

    def asg_client
      @asg_client ||= Aws::AutoScaling::Client.new(get_client_options)
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

    def ecs_client
      @ecs_client ||= Aws::ECS::Client.new(get_client_options)
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


