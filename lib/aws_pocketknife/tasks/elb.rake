require_relative '../elb'
require_relative '../cli/elb'

elb_cli = AwsPocketknife::Cli::Elb.new

namespace :elb do

  desc 'Describe load balancer by name'
  task :describe, [:elb_name]  do |t, args|
    elb_cli.desc args[:elb_name]
  end

end