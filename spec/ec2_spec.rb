require 'rspec'
require 'spec_helper'

describe AwsPocketknife::Ec2 do

  let(:snapshot_id) { 'snap-12345678' }
  let(:image_id) {'ami-1234567'}
  let(:instance_id) {'i-1234'}
  let(:user_id) { '12345678' }
  let(:ec2_client) {instance_double(Aws::EC2::Client)}

  before (:each) do
    allow(AwsPocketknife::Ec2).to receive(:ec2_client).and_return(ec2_client)
  end

  describe '#share_ami' do

    it 'should call modify_image_attribute with success' do

    end
  end

  describe '#find_unused_ami' do

    let(:image_ids) {['1', '2', '3']}

    before (:each) do
      allow(Kernel).to receive(:sleep)
    end

    it 'should return list with ami that can be deleted' do

      first_response = [get_instance_response(instance_id: 'i-1')]
      second_response = [get_instance_response(instance_id: 'i-2')]
      third_response = []

      allow(AwsPocketknife::Ec2).to receive(:describe_instances_by_image_id).and_return(first_response, second_response, third_response)

      images_to_delete = AwsPocketknife::Ec2.find_unused_ami(image_ids: image_ids)
      expect(images_to_delete).to eq(['3'])

    end

    it 'should return empty list when all amis are in use' do

      first_response = [get_instance_response(instance_id: 'i-1')]
      second_response = [get_instance_response(instance_id: 'i-2')]

      allow(AwsPocketknife::Ec2).to receive(:describe_instances_by_image_id).and_return(first_response, second_response)

      images_to_delete = AwsPocketknife::Ec2.find_unused_ami(image_ids: image_ids)
      expect(images_to_delete).to eq([])

    end

  end

  describe '#find_ami_by_creation_time' do

    let(:days) {'15'}
    let(:ami_name_pattern) {'test-*'}
    let(:options) { {days: days, ami_name_pattern: ami_name_pattern} }

    it 'should return list of amis with creation time greater than days' do

      first_response = get_image_response image_id: '1', date: '2013-12-16 11:57:42 +1100'
      second_response = get_image_response image_id: '2', date: '2040-12-16 11:57:42 +1100'

      allow(subject).to receive(:find_ami_by_name).and_return([first_response, second_response])

      image_ids = subject.find_ami_by_creation_time(options)
      expect(image_ids).to eq(['2'])

    end

    it 'should return empty list when no AMIs can be found with creation time greater than days' do

      first_response = get_image_response image_id: '1', date: '2013-12-15 11:57:42 +1100'
      second_response = get_image_response image_id: '2', date: '2013-12-16 11:57:42 +1100'

      allow(subject).to receive(:find_ami_by_name).and_return([first_response, second_response])

      image_ids = subject.find_ami_by_creation_time(options)
      expect(image_ids).to eq([])

    end


  end

  describe '#delete_ami_by_id' do

    it 'should delete ami with sucess' do

      first_response = get_image_response image_id: '1', date: '2013-12-15 11:57:42 +1100', state: AwsPocketknife::Ec2::STATE_PENDING
      second_response = get_image_response image_id: '1', date: '2013-12-15 11:57:42 +1100', state: AwsPocketknife::Ec2::STATE_PENDING
      third_response = get_image_response image_id: '1', date: '2013-12-15 11:57:42 +1100', state: AwsPocketknife::Ec2::STATE_DEREGISTERED
      fourth_response = get_image_response image_id: ''

      allow(subject).to receive(:find_ami_by_id).and_return(first_response, second_response, third_response, fourth_response)
      allow(ec2_client).to receive(:deregister_image).with(image_id: image_id)
      allow(ec2_client).to receive(:deregister_image).with(image_id: image_id)
      allow(Kernel).to receive(:sleep)

      expect(ec2_client).to receive(:delete_snapshot).with(snapshot_id: snapshot_id)
      expect(subject).to receive(:find_ami_by_id).with(id: image_id).exactly(4).times()

      subject.delete_ami_by_id(id: image_id)

    end
  end


  describe '#stop_instance_by_id' do

    it 'should stop one instance' do

      instance_id = "1"

      allow(subject).to receive(:wait_till_instance_is_stopped).and_return("mock")

      allow(ec2_client).to receive(:stop_instances).with({ instance_ids: ["1"] })
      expect(ec2_client).to receive(:stop_instances).with({ instance_ids: ["1"] })

      subject.stop_instance_by_id(instance_id)
    end

    it 'should stop list of instances' do

      instance_id = "1;2;3"

      allow(subject).to receive(:wait_till_instance_is_stopped).and_return("mock")

      allow(ec2_client).to receive(:stop_instances).with({ instance_ids: ["1", "2", "3"] })
      expect(ec2_client).to receive(:stop_instances).with({ instance_ids: ["1", "2", "3"] })

      subject.stop_instance_by_id(instance_id)
    end

  end

  describe '#start_instance_by_id' do

    it 'should start one instance' do

      instance_id = "1"

      allow(ec2_client).to receive(:start_instances).with({ instance_ids: ["1"] })
      expect(ec2_client).to receive(:start_instances).with({ instance_ids: ["1"] })

      subject.start_instance_by_id(instance_id)

    end

    it 'should start list of instances' do

      instance_id = "1;2;3"

      allow(ec2_client).to receive(:start_instances).with({ instance_ids: ["1", "2", "3"] })
      expect(ec2_client).to receive(:start_instances).with({ instance_ids: ["1", "2", "3"] })

      subject.start_instance_by_id(instance_id)
    end

  end

  describe '#describe_instances_by_name' do

    it 'should describe instances by name' do

      name = "test"

      aws_response = get_aws_response({reservations: [
          {instances: [{instance_id: instance_id}]}
      ]})

      allow(ec2_client).to receive(:describe_instances)
                                                      .with({dry_run: false,
                                                             filters: [
                                                                 {
                                                                     name: "tag:Name",
                                                                     values: [name]
                                                                 }
                                                             ]})
                                                      .and_return(aws_response)

      instances = subject.find_by_name(name: name)
      expect(instances.first.instance_id).to eq(instance_id)
    end
  end

  describe '#describe_instance_by_id' do

    it 'should return nil when instance id is not found' do
      instance_id = "i-test"

      aws_response = get_aws_response({reservations: [
          {instances: []}
      ]})

      allow(ec2_client).to receive(:describe_instances)
                                                      .with({dry_run: false, instance_ids: [instance_id]})
                                                      .and_return(aws_response)

      instance = subject.find_by_id(instance_id: instance_id)
      expect(instance).to eq(nil)
    end

    it 'should return instance' do
      instance_id = "i-test"

      aws_response = RecursiveOpenStruct.new({reservations: [
          {instances: [{instance_id: instance_id}]}
      ]}, recurse_over_arrays: true)

      allow(ec2_client).to receive(:describe_instances)
                                                      .with({dry_run: false, instance_ids: [instance_id]})
                                                      .and_return(aws_response)

      instance = subject.find_by_id(instance_id: instance_id)
      expect(instance).to_not eq(nil)
      expect(instance.instance_id).to eq(instance_id)
    end

  end

  describe '#get_windows_password' do

    let (:instance_id) { "i-test" }

    it 'should retrieve windows password with success' do
      private_keyfile_dir = "dir"
      key_name = "my_key"
      encrypted_password = "sdjadaldl"
      private_keyfile = "test"
      
      aws_response = get_aws_response({password_data: encrypted_password})


      allow(ec2_client).to receive(:get_password_data).with({dry_run: false, instance_id: instance_id})
                                                      .and_return(aws_response)

      allow(ENV).to receive(:[]).with("AWS_POCKETKNIFE_KEYFILE_DIR").and_return(private_keyfile_dir)
      allow(subject).to receive(:find_by_id)
                                        .with(instance_id: instance_id)
                                        .and_return(RecursiveOpenStruct.new({key_name: key_name},
                                                                            recurse_over_arrays: true))
      allow(File).to receive(:exist?)
                         .with("test").and_return(true)
      allow(File).to receive(:join)
                         .with(private_keyfile_dir, "#{key_name}.pem").and_return(private_keyfile)
      allow(subject).to receive(:decrypt_windows_password)
                                        .with(encrypted_password, private_keyfile)
                                        .and_return("my_password")


      instance = subject.get_windows_password(instance_id: instance_id)
      expect(instance.password).to eq("my_password")
    end
  end
end
