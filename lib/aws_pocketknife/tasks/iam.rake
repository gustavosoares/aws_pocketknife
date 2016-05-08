require_relative "../iam"

namespace :iam do

  desc 'List ssl certificates'
  task :list_ssl_certificates do
    certs = AwsPocketknife::Iam.list_ssl_certificates
    AwsPocketknife::Iam.nice_print(object: certs.to_h)
  end

  desc 'Create IAM User'
  task :create_user, [:username]  do |_t, args|
    AwsPocketknife::Iam.create_iam_user(args[:username])
  end

  desc 'Create IAM Group'
  task :create_group, [:group_name]  do |_t, args|
    AwsPocketknife::Iam.create_group(args[:group_name])
  end

  desc 'Create IAM Policy from file. You pass list of s3 buckets like so: s1bucket;s2bucket'
  task :create_policy, [:policy_name,:policy_file,:s3_buckets]  do |_t, args|
    AwsPocketknife::Iam.create_policy_from_policy_file(policy_name: args[:policy_name], policy_file: args[:policy_file], s3_buckets: args[:s3_buckets])
  end

  desc 'Attach IAM Policy to Group'
  task :attach_policy_to_group, [:policy_name,:group_name]  do |_t, args|
    AwsPocketknife::Iam.attach_policy_to_group(args[:policy_name],args[:group_name])
  end

  desc 'Add user to Group'
  task :attach_user_to_group, [:username,:group_name]  do |_t, args|
    AwsPocketknife::Iam.add_user_to_group(args[:username],args[:group_name])
  end

  desc 'Create Role'
  task :create_role, [:role_name,:trust_relationship_file]  do |_t, args|
    AwsPocketknife::Iam.create_role(args[:role_name],args[:trust_relationship_file])
  end

  desc 'Attach policy to role'
  task :attach_policy_to_role, [:role_name,:policy_name]  do |_t, args|
    AwsPocketknife::Iam.attach_policy_to_role(args[:role_name],args[:policy_name])
  end

  desc 'Create Instance Profile'
  task :create_instance_profile, [:instance_profile_name]  do |_t, args|
    AwsPocketknife::Iam.create_instance_profile(args[:instance_profile_name])
  end

  desc 'Add Role to Instance Profile'
  task :add_role_to_instance_profile, [:instance_profile_name,:role_name]  do |_t, args|
    AwsPocketknife::Iam.add_role_to_instance_profile(args[:role_name],args[:instance_profile_name])
  end
end
