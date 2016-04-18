require_relative '../ec2'

namespace :ec2 do

  desc 'Stop instance by id'
  task :stop_by_id, [:instance_id]  do |t, args|
    AwsPocketknife::Ec2.stop_instance_by_id(args[:instance_id])
  end

  desc 'Start instance by id'
  task :start_by_id, [:instance_id]  do |t, args|
    AwsPocketknife::Ec2.start_instance_by_id(args[:instance_id])
  end

end