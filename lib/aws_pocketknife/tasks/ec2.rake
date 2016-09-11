require_relative '../ec2'
require_relative '../cli/ec2'
require_relative '../cli/ami'

ec2_cli = AwsPocketknife::Cli::Ec2.new
ami_cli = AwsPocketknife::Cli::Ami.new

namespace :ec2 do

  namespace :ami do
    desc 'share ami'
    task :share, [:image_id, :user_id]  do |t, args|
      AwsPocketknife::Ec2.share_ami(image_id: args[:instance_id], user_id: args[:instance_id])
    end

    desc "clean up old AMIs."
    task :clean, [:ami_name_pattern, :days, :dry_run] do |t, args|
      args.with_defaults(:dry_run => "true")
      ami_name_pattern = args[:ami_name_pattern]
      days = args[:days]
      args[:dry_run].strip.downcase == "true" ? dry_run = true : dry_run = false
      AwsPocketknife::Cli::Ami.options = {:dry_run => dry_run}
      ami_cli.clean ami_name_pattern, days
    end
  end

  desc 'Stop instance by id'
  task :stop_by_id, [:instance_id]  do |t, args|
    ec2_cli.stop(args[:instance_id])
  end

  desc 'Start instance by id'
  task :start_by_id, [:instance_id]  do |t, args|
    ec2_cli.start(args[:instance_id])
  end

  desc 'Describe instance by id'
  task :find_by_id, [:instance_id]  do |t, args|
    ec2_cli.find_by_id(args[:instance_id])
  end

  desc 'Describe instance by name'
  task :describe_instance_by_name, [:name]  do |t, args|
    ec2_cli.find_by_name(args[:name])
  end

  desc 'Find instances by name'
  task :find_by_name, [:name]  do |t, args|
    ec2_cli.find_by_name(args[:name])
  end

  desc 'Get windows password'
  task :get_windows_password, [:instance_id]  do |t, args|
    ec2_cli.get_windows_password(args[:instance_id])
  end

end