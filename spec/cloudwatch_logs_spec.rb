require 'rspec'
require 'spec_helper'

require 'aws_pocketknife/cloudwatch_logs'

describe AwsPocketknife::CloudwatchLogs do

  let(:cloudwatch_logs_client) {instance_double(Aws::CloudWatchLogs::Client)}

  before (:each) do
    allow(subject).to receive(:cloudwatch_logs_client).and_return(cloudwatch_logs_client)
  end

  describe '#create_log_group' do

    it 'should create log group given a log group name' do

      log_group_name = "test"

      allow(cloudwatch_logs_client).to receive(:create_log_group)
                                                      .with({
                                                                log_group_name: log_group_name, # required
                                                            })
      expect(cloudwatch_logs_client).to receive(:create_log_group)
                                           .with({
                                                     log_group_name: log_group_name, # required
                                                 })

      subject.create_log_group(log_group_name: log_group_name)
    end

    it 'should not create log group when log group name is empty' do

      log_group_name = ''

      expect(cloudwatch_logs_client).not_to receive(:create_log_group)

      subject.create_log_group(log_group_name: log_group_name)

    end

  end
end
