require 'rspec'
require 'spec_helper'
require 'aws_pocketknife/ec2'


describe AwsPocketknife::Ec2 do

  def get_image_response(image_id: '', date: '2040-12-16 11:57:42 +1100')
    RecursiveOpenStruct.new({image_id: image_id,
                             tags: [
                                 {key: "Date", value: date}
                             ]
                             },
                             recurse_over_arrays: true)
  end

  def get_instance_response(instance_id: '')
    RecursiveOpenStruct.new({instance_id: instance_id},
                            recurse_over_arrays: true)
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

    before (:each) do
      AwsPocketknife.instance_variable_set(:@aws_helper_ec2_client, nil)
    end

    it 'should return list of amis with creation time greater than days' do

      first_response = get_image_response image_id: '1', date: '2013-12-16 11:57:42 +1100'
      second_response = get_image_response image_id: '2', date: '2040-12-16 11:57:42 +1100'

      allow(AwsPocketknife::Ec2).to receive(:find_ami_by_name).and_return([first_response, second_response])

      image_ids = AwsPocketknife::Ec2.find_ami_by_creation_time(options)
      expect(image_ids).to eq(['2'])

    end

    it 'should return empty list when no AMIs can be found with creation time greater than days' do

      first_response = get_image_response image_id: '1', date: '2013-12-15 11:57:42 +1100'
      second_response = get_image_response image_id: '2', date: '2013-12-16 11:57:42 +1100'

      allow(AwsPocketknife::Ec2).to receive(:find_ami_by_name).and_return([first_response, second_response])

      image_ids = AwsPocketknife::Ec2.find_ami_by_creation_time(options)
      expect(image_ids).to eq([])

    end


  end

  describe '#delete_ami_by_id' do

    let(:image_id) {'ami-1234567'}
    let(:ec2_client) {instance_double(Aws::EC2::Client)}
    let(:aws_helper_ec2_client) {instance_double(AwsHelpers::EC2)}

    it 'should delete ami with sucess' do

      allow(AwsPocketknife::Ec2).to receive(:aws_helper_ec2_client).and_return(aws_helper_ec2_client)
      allow(aws_helper_ec2_client).to receive(:image_delete).with(image_id)
      expect(aws_helper_ec2_client).to receive(:image_delete).with(image_id)

      AwsPocketknife::Ec2.delete_ami_by_id(id: image_id)

    end
  end


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

  describe '#describe_instances_by_name' do

    it 'should describe instances by name' do

      name = "test"

      aws_response = RecursiveOpenStruct.new({reservations: [
          {instances: []}
      ]}, recurse_over_arrays: true)

      expect_any_instance_of(Aws::EC2::Client).to receive(:describe_instances)
                                                      .with({dry_run: false,
                                                             filters: [
                                                                 {
                                                                     name: "tag:Name",
                                                                     values: [name]
                                                                 }
                                                             ]})
                                                      .and_return(aws_response)

      instances = AwsPocketknife::Ec2.describe_instances_by_name(name: name)
    end
  end

  describe '#describe_instance_by_id' do

    it 'should return nil when instance id is not found' do
      instance_id = "i-test"

      aws_response = get_aws_response({reservations: [
          {instances: []}
      ]})

      expect_any_instance_of(Aws::EC2::Client).to receive(:describe_instances)
                                                      .with({dry_run: false, instance_ids: [instance_id]})
                                                      .and_return(aws_response)

      instance = AwsPocketknife::Ec2.describe_instance_by_id(instance_id: instance_id)
      expect(instance).to eq(nil)
    end

    it 'should return instance' do
      instance_id = "i-test"

      aws_response = RecursiveOpenStruct.new({reservations: [
          {instances: [{instance_id: instance_id}]}
      ]}, recurse_over_arrays: true)

      expect_any_instance_of(Aws::EC2::Client).to receive(:describe_instances)
                                                      .with({dry_run: false, instance_ids: [instance_id]})
                                                      .and_return(aws_response)

      instance = AwsPocketknife::Ec2.describe_instance_by_id(instance_id: instance_id)
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
      
      aws_response = RecursiveOpenStruct.new({password_data: encrypted_password}, recurse_over_arrays: true)


      expect_any_instance_of(Aws::EC2::Client).to receive(:get_password_data)
                                                      .with({dry_run: false, instance_id: instance_id})
                                                      .and_return(aws_response)

      allow(ENV).to receive(:[]).with("AWS_POCKETKNIFE_KEYFILE_DIR").and_return(private_keyfile_dir)
      allow(AwsPocketknife::Ec2).to receive(:describe_instance_by_id)
                                        .with(instance_id: instance_id)
                                        .and_return(RecursiveOpenStruct.new({key_name: key_name},
                                                                            recurse_over_arrays: true))
      allow(File).to receive(:exist?)
                         .with("test").and_return(true)
      allow(File).to receive(:join)
                         .with(private_keyfile_dir, "#{key_name}.pem").and_return(private_keyfile)
      allow(AwsPocketknife::Ec2).to receive(:decrypt_windows_password)
                                        .with(encrypted_password, private_keyfile)
                                        .and_return("my_password")


      instance = AwsPocketknife::Ec2.get_windows_password(instance_id: instance_id)
      expect(instance.password).to eq("my_password")
    end
  end
end
