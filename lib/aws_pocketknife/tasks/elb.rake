require_relative '../elb'

namespace :elb do

  desc 'Describe load balancer by name'
  task :describe, [:elb_name]  do |t, args|
    elb = AwsPocketknife::Elb.describe_elb_by_name(name: args[:elb_name])
    if elb.nil?
      puts "ELB #{args[:elb_name]} not found"
    else
      AwsPocketknife::Ec2.nice_print(object: elb.to_h)
    end
  end

end