require 'aws_helpers'
require 'aws_pocketknife'

module AwsPocketknife
  module Iam

    @iamClient = AwsPocketknife.iam_client

    class << self

      def create_iam_user(username)
        puts "Creating iam user: #{username}"
        @iamClient.create_user({user_name: username})
        puts "Iam user: #{username} created"
      end

      def create_group(group_name)
        puts "Creating group: #{group_name}"
        @iamClient.create_group({group_name: group_name})
        puts "Created group: #{group_name}"
      end

      def create_policy(policy_name, policy)
        puts "Creating policy: #{policy_name}"
        @iamClient.create_policy({policy_name: policy_name,policy_document: policy})
        puts "Created policy: #{policy_name}"
      end

      def create_policy_from_policy_file(policy_name,policy_file,s3_buckets_one,s3_buckets_two)
        puts "Creating policy #{policy_name} from saved policy #{policy_file}"
        policy = IO.read(policy_file)

        unless s3_buckets_one.nil?
          puts "Replacing [%S3Bucket1%] with #{s3_buckets_one}"
          policy.gsub! '[%S3Bucket1%]', s3_buckets_one
        else
          policy.gsub! '[%S3Bucket1%]', ''
        end

        unless s3_buckets_two.nil?
          puts "Replacing [%S3Bucket2%] with #{s3_buckets_two}"
          policy.gsub! '[%S3Bucket2%]', "#{s3_buckets_two}"
        else
          policy.gsub! '[%S3Bucket2%]', ''
        end

        puts policy

        unless (policy.nil?)
          @iamClient.create_policy({policy_name: policy_name, policy_document: policy})
        else
          puts 'Policy not found'
        end
        puts "Created Policy #{policy_name}"
      end

      def attach_policy_to_group(policy_name, group_name )
        puts "Attaching policy #{policy_name} to group #{group_name}"
        arn_number = get_policy_arn(policy_name)

        unless arn_number.nil?
          @iamClient.attach_group_policy(group_name: group_name, policy_arn: arn_number)
        else
          puts "The policy #{policy_name} could not be found"
        end
        puts "Policy #{policy_name} attached to group #{group_name}"
      end

      def add_user_to_group(username,group_name)
        puts "Attaching user: #{username} to group: #{group_name}"
        @iamClient.add_user_to_group(group_name: group_name, user_name: username)
        puts "User: #{username} attached to group: #{group_name}"

      end

      def create_role(role_name, trust_relationship_file)
        begin
          if File.exist?(trust_relationship_file)
            trust_relationship = IO.read(trust_relationship_file)
            unless trust_relationship.nil?
              puts "Creating role: #{role_name} with trust relationship #{trust_relationship}"
              @iamClient.create_role(role_name: role_name, assume_role_policy_document: trust_relationship)
              puts "Created role: #{role_name} with trust relationship #{trust_relationship}"
            else
              raise "Trust Relationship file could not be loaded"
            end
          else
            raise "Trust Relationship file could not be loaded"
          end
        rescue Exception => e
          puts e
          raise e
        end
      end

      def attach_policy_to_role(role_name, policy_name)
        arn_number = get_policy_arn(policy_name)
        unless arn_number.nil?
          puts "Attach policy: #{policy_name} to role: #{role_name}"
          @iamClient.attach_role_policy(role_name: role_name, policy_arn: arn_number)
          puts "Attached policy: #{policy_name} to role: #{role_name}"
        else
          raise "The policy #{policy_name} could not be found"
        end
      end

      def create_instance_profile(instance_profile_name)
        puts "Creating instance profile: #{instance_profile_name}"
        @iamClient.create_instance_profile(instance_profile_name: instance_profile_name)
        puts "Created instance profile: #{instance_profile_name}"
      end

      def add_role_to_instance_profile(role_name,instance_profile_name)
        puts "Adding role #{role_name} to instance profile: #{instance_profile_name}"
        @iamClient.add_role_to_instance_profile(instance_profile_name: instance_profile_name,role_name: role_name)
        puts "Added role #{role_name} to instance profile: #{instance_profile_name}"
      end


      private

      def get_policy_arn(policy_name)
        response = @iamClient.list_policies({scope: 'Local'})
        arn_number = nil
        response.policies.each do |value|
          if value.policy_name == policy_name
            arn_number = value.arn
            break;
          end
        end
        arn_number
      end

    end

  end
end
