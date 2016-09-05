require 'rspec'
require 'spec_helper'
require 'aws_pocketknife/ec2'


describe AwsPocketknife::Ec2 do

  let(:aws_helper_ec2_client) { instance_double(AwsHelpers::EC2) }
  let(:aws_ec2_client) { instance_double(Aws::EC2::Client) }

  # describe '#clean_ami' do
  #
  #   before (:each) do
  #     AwsPocketknife.instance_variable_set(:@aws_helper_ec2_client, aws_helper_ec2_client)
  #     AwsPocketknife.instance_variable_set(:@ec2_client, aws_ec2_client)
  #     allow(Kernel).to receive(:sleep)
  #   end
  #
  #   let(:days) {'15'}
  #   let(:ami_name_pattern) {'test-*'}
  #   let(:image_response) {[get_image_response(image_id: '1'),
  #                          get_image_response(image_id: '2'),
  #                          get_image_response(image_id: '3')]}
  #
  #   it 'should clean old amis' do
  #
  #     allow(aws_helper_ec2_client).to receive(:images_find_by_tags)
  #                                         .with(Name: ami_name_pattern).and_return(image_response)
  #     expect(aws_helper_ec2_client).to receive(:images_find_by_tags).with(Name: ami_name_pattern)
  #     expect_any_instance_of(AwsPocketknife::Ec2).to receive(:describe_instances_by_image_id).with(image_id_list: ['1'])
  #
  #     AwsPocketknife::Ec2.clean_ami(ami_name_pattern: ami_name_pattern)
  #     expect(true).to eq(true)
  #
  #   end
  #
  # end

  def get_image_response(image_id: '', date: '2040-12-16 11:57:42 +1100')
    RecursiveOpenStruct.new({image_id: image_id,
                             tags: [
                                 {key: "Date", value: date}
                             ]
                             },
                             recurse_over_arrays: true)
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
