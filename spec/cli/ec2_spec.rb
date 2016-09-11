require 'rspec'
require 'spec_helper'

require 'aws_pocketknife/cli/ec2'

describe AwsPocketknife::Cli::Ec2 do

  let(:instance_name) {'test-*'}
  let(:instance_id) {'i-1234'}

  describe '#find_by_name' do

    it 'should call find_by_name with the right arguments' do


      allow(AwsPocketknife::Ec2).to receive(:find_by_name).with(name: instance_name).and_return([])
      allow(AwsPocketknife::Ec2).to receive(:pretty_table)

      expect(AwsPocketknife::Ec2).to receive(:find_by_name).with(name: instance_name)

      subject.find_by_name instance_name

    end

  end

  describe '#find_by_id' do

    it 'should call find_by_id with the right arguments' do

      aws_response = get_instance_response instance_id: instance_id

      allow(AwsPocketknife::Ec2).to receive(:find_by_id)
                                        .with(instance_id: instance_id).and_return(aws_response)
      allow(AwsPocketknife::Ec2).to receive(:nice_print)

      expect(AwsPocketknife::Ec2).to receive(:find_by_id).with(instance_id: instance_id)
      expect(AwsPocketknife::Ec2).to receive(:nice_print)

      subject.find_by_id instance_id

    end

    it 'should call find_by_id with the right arguments and get back a nil response' do

      allow(AwsPocketknife::Ec2).to receive(:find_by_id)
                                        .with(instance_id: instance_id).and_return(nil)
      allow(AwsPocketknife::Ec2).to receive(:nice_print)

      expect(AwsPocketknife::Ec2).to receive(:find_by_id).with(instance_id: instance_id)
      expect(AwsPocketknife::Ec2).not_to receive(:nice_print)

      subject.find_by_id instance_id

    end

  end

  describe '#get_windows_password' do

    it 'should call get_windows_password with the right arguments' do

      aws_response = get_instance_response instance_id: instance_id

      allow(AwsPocketknife::Ec2).to receive(:get_windows_password)
                                        .with(instance_id: instance_id).and_return(aws_response)
      allow(AwsPocketknife::Ec2).to receive(:pretty_table)

      expect(AwsPocketknife::Ec2).to receive(:get_windows_password).with(instance_id: instance_id)
      expect(AwsPocketknife::Ec2).to receive(:pretty_table)

      subject.get_windows_password instance_id

    end

  end

  describe '#stop' do

    it 'should call stop with the right arguments' do

      allow(AwsPocketknife::Ec2).to receive(:stop_instance_by_id)
                                        .with(instance_id)
      expect(AwsPocketknife::Ec2).to receive(:stop_instance_by_id).with(instance_id)

      subject.stop instance_id

    end

  end

  describe '#start' do

    it 'should call stop with the right arguments' do

      allow(AwsPocketknife::Ec2).to receive(:start_instance_by_id)
                                        .with(instance_id)
      expect(AwsPocketknife::Ec2).to receive(:start_instance_by_id).with(instance_id)

      subject.start instance_id

    end

  end

end
