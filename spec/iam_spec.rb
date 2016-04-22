require 'rspec'
require "rspec/expectations"
require 'spec_helper'

require 'aws_pocketknife/iam'


describe AwsPocketknife::Iam do

  describe "#create_user" do
    it 'Create an iam user with the supplied username' do
      # Setup
      user = 'testUser'

      # Act
      # Verify
      expect_any_instance_of(Aws::IAM::Client).to receive(:create_user).with({user_name:user})
      AwsPocketknife::Iam.create_iam_user(user)
    end
  end

  describe "#create_policy" do
    it 'Should create a policy within aws with the supplied policy name and policy' do

      policy_name = 'testUser'
      policy = '{
                  "Version": "2012-10-17",
                  "Statement": [
                    {
                      "Action": "ec2:*",
                      "Effect": "Allow",
                      "Resource": "*"
                    }
                  ]
                }'

      expect_any_instance_of(Aws::IAM::Client).to receive(:create_policy).with({policy_name:policy_name,policy_document:policy})
      AwsPocketknife::Iam.create_policy(policy_name,policy)

    end

    it 'Should create a policy within aws from a saved policy file' do

      policy_name = 'testUser'
      s3bucket1 = 'bucket1'
      s3bucket2 = 'bucket2'
      policy_file = "devops.json"
      io_read = '"Resource": [
        "[%S3Bucket1%]",
        "[%S3Bucket2%]"
      ]'
      allow(IO).to receive(:read).with(File.join(policy_file)).and_return(io_read)
      policy = IO.read(policy_file)
      policy.gsub! '[%S3Bucket1%]', s3bucket1
      policy.gsub! '[%S3Bucket2%]', s3bucket2

      expect_any_instance_of(Aws::IAM::Client).to receive(:create_policy).with({policy_name:policy_name,policy_document:policy})
      AwsPocketknife::Iam.create_policy_from_policy_file(policy_name,policy_file,s3bucket1,s3bucket2)

    end

    it 'Should create a policy within aws from a saved policy file and replace values' do
      # Setup

      policy_name = 'testUser'
      policy_file = "devops.json"
      # aws_client = target.instance_variable_get(:@iamClient)
      # allow(aws_client).to receive(:create_policy)
      io_read = '"Resource": [
        "[%S3Bucket1%]",
        "[%S3Bucket2%]"
      ]'
      allow(IO).to receive(:read).with(File.join(policy_file)).and_return(io_read)

      # Act
      printed = capture_stdout do
        AwsPocketknife::Iam.create_policy_from_policy_file(policy_name,policy_file,"bucket1","bucket2")
      end
      # Verify
      expect(printed).to include('Replacing [%S3Bucket1%] with bucket1')
      expect(printed).to include('Replacing [%S3Bucket2%] with bucket2')
    end
  end

  describe "#attach_policy_to_group" do
    it 'Should attach a policy defined within aws to a user'do
      # Setup
      group_name = 'testGroup'
      policy_name = 'testPolicy'
      arn_number = '123'

      # Verify
      allow(AwsPocketknife::Iam).to receive(:get_policy_arn).with(policy_name).and_return(arn_number)
      expect_any_instance_of(Aws::IAM::Client).to receive(:attach_group_policy).with(group_name: group_name, policy_arn: arn_number)
      AwsPocketknife::Iam.attach_policy_to_group(policy_name, group_name)


    end

    it 'Should log when the policy cannot be found' do
      # Setup
      # Setup
      group_name = 'testGroup'
      policy_name = 'testPolicy'

      # Act
      printed = capture_stdout do
        AwsPocketknife::Iam.attach_policy_to_group(policy_name, group_name)
      end

      # Verify
      expect(printed).to include("The policy #{policy_name} could not be found")

    end

  end

  describe "#add_user_to_group" do
    it 'Should associate the defined user and group together'do
      # Setup
      group_name = 'testGroup'
      username = 'testuser'

      # Act
      expect_any_instance_of(Aws::IAM::Client).to receive(:add_user_to_group).with({group_name:group_name,user_name:username})
      printed = capture_stdout do
        AwsPocketknife::Iam.add_user_to_group(username,group_name)
      end

      # Assert
      expect(printed).to include("Attaching user: #{username} to group: #{group_name}")
    end


  end

  describe "#create_role"do
    #Need to be able to load a file which dir are tests run from ?
    it 'should create a row within aws using the specified role name and policy'do
      # Setup
      role_name = "testRole"
      trust_relationship_file = "file.json"
      trust_relationship = "mock"

      allow(IO).to receive(:read).with(trust_relationship_file).and_return(trust_relationship)
      allow(File).to receive(:exist?).with(trust_relationship_file).and_return(true)

      expect_any_instance_of(Aws::IAM::Client).to receive(:create_role).with(role_name: role_name, assume_role_policy_document: trust_relationship)

      # Act
      printed = capture_stdout do
        AwsPocketknife::Iam.create_role(role_name,trust_relationship_file)
      end

      # Assert
      expect(printed).to include("Creating role: #{role_name} with trust relationship #{trust_relationship}")
      expect(printed).to include("Created role: #{role_name} with trust relationship #{trust_relationship}")

    end

    it 'should not create role when trust relationship document cannot be loaded' do
      # Setup
      role_name = "testRole"
      trust_relationship_file = 'trustrelationshipfile'

      # Act
      expect{AwsPocketknife::Iam.create_role(role_name,trust_relationship_file)}.to raise_error(message= "Trust Relationship file could not be loaded")


    end

  end

  describe "#attach_policy_to_role" do
    it 'Should attach the supplied policy to supplied role' do
      # Setup
      role = 'role'
      policy = 'policy'

      # Act
      allow(AwsPocketknife::Iam).to receive(:get_policy_arn).and_return('123')

      expect_any_instance_of(Aws::IAM::Client).to receive(:attach_role_policy).with({role_name:role,policy_arn:'123'})

      # Act
      printed = capture_stdout do
        AwsPocketknife::Iam.attach_policy_to_role(role,policy)
      end

    end

    it 'should throw and exception when the arn number of the policy cannot be found'do
      # Setup
      role = 'role'
      policy = 'policy'

      # Act
      allow(AwsPocketknife::Iam).to receive(:get_policy_arn).and_return(nil)
      expect{AwsPocketknife::Iam.attach_policy_to_role(role,policy)}.to raise_error(message="The policy #{policy} could not be found")


    end
  end

  describe "#create_instance_profile"do
    it 'should add an instance profile within aws with the supplied instance profile name'do
      instance_profile_name = 'instanceProfileName'

      expect_any_instance_of(Aws::IAM::Client).to receive(:create_instance_profile).with(instance_profile_name: instance_profile_name)

      # Act
      printed = capture_stdout do
        AwsPocketknife::Iam.create_instance_profile(instance_profile_name)
      end

      # Assert
      expect(printed).to include("Creating instance profile: #{instance_profile_name}")
      expect(printed).to include("Created instance profile: #{instance_profile_name}")

    end
  end

  describe "#add_role_to_instance_profile"do
    it 'should add the supplied role to the supplied instance profile'do
      instance_profile_name = 'instanceProfileName'
      role_name = 'roleName'

      expect_any_instance_of(Aws::IAM::Client).to receive(:add_role_to_instance_profile).with(instance_profile_name: instance_profile_name, role_name: role_name)

      # Act
      printed = capture_stdout do
        AwsPocketknife::Iam.add_role_to_instance_profile(role_name, instance_profile_name)
      end

      # Assert
      expect(printed).to include("Adding role #{role_name} to instance profile: #{instance_profile_name}")
      expect(printed).to include("Added role #{role_name} to instance profile: #{instance_profile_name}")


    end
  end


end
