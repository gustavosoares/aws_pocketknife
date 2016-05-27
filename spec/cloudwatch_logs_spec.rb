require 'rspec'
require 'spec_helper'

require 'aws_pocketknife/cloudwatch_logs'

describe AwsPocketknife::CloudwatchLogs do

  describe '#create_log_group' do

    it 'should create log group given a log group name' do

      log_group_name = "test"

      expect_any_instance_of(Aws::CloudWatchLogs::Client).to receive(:create_log_group)
                                                      .with({
                                                                log_group_name: log_group_name, # required
                                                            })

      AwsPocketknife::CloudwatchLogs.create_log_group(log_group_name: log_group_name)
    end

    it 'should not create log group when log group name is empty' do

      log_group_name = ""

      expect_any_instance_of(Aws::CloudWatchLogs::Client).not_to receive(:create_log_group)

      AwsPocketknife::CloudwatchLogs.create_log_group(log_group_name: log_group_name)

    end

  end
end
