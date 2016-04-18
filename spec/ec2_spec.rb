require 'rspec'
require 'spec_helper'

require 'aws_pocketknife/ec2'

describe '#stop_instance_by_id' do

  it 'should stop instance' do

    instance_id = "1"

    allow(AwsPocketknife::Ec2).to receive(:wait_till_instance_is_stopped).and_return("mock")

    printed = capture_stdout do
      AwsPocketknife::Ec2.stop_instance_by_id(instance_id)
    end

    expect(printed).to include("Stoping instance id: #{instance_id}")
  end


end

describe '#start_instance_by_id' do

  it 'should start instance' do

    instance_id = "1"

    printed = capture_stdout do
      AwsPocketknife::Ec2.start_instance_by_id(instance_id)
    end

    expect(printed).to include("Start instance id: #{instance_id}")
  end


end