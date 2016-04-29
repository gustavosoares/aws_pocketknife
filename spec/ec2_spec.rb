require 'rspec'
require 'spec_helper'

require 'aws_pocketknife/ec2'

describe '#stop_instance_by_id' do

  it 'should stop one instance' do

    instance_id = "1"

    allow(AwsPocketknife::Ec2).to receive(:wait_till_instance_is_stopped).and_return("mock")

    expect_any_instance_of(Aws::EC2::Client).to receive(:stop_instances)
                                                    .with({ instance_ids: ["1"] })

    AwsPocketknife::Ec2.stop_instance_by_id(instance_id)
  end

  it 'should stop list of instances' do

    instance_id = "1;2;3"

    allow(AwsPocketknife::Ec2).to receive(:wait_till_instance_is_stopped).and_return("mock")

    expect_any_instance_of(Aws::EC2::Client).to receive(:stop_instances)
                                                    .with({ instance_ids: ["1", "2", "3"] })

    AwsPocketknife::Ec2.stop_instance_by_id(instance_id)
  end

end

describe '#start_instance_by_id' do

  it 'should start one instance' do

    instance_id = "1"

    expect_any_instance_of(Aws::EC2::Client).to receive(:start_instances)
                                                    .with({ instance_ids: ["1"] })
    AwsPocketknife::Ec2.start_instance_by_id(instance_id)

  end

  it 'should start list of instances' do

    instance_id = "1;2;3"

    expect_any_instance_of(Aws::EC2::Client).to receive(:start_instances)
                                                    .with({ instance_ids: ["1", "2", "3"] })
    AwsPocketknife::Ec2.start_instance_by_id(instance_id)
  end

end