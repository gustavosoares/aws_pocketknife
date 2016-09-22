require_relative '../asg'
require_relative '../cli/asg'

asg_cli = AwsPocketknife::Cli::Asg.new

namespace :asg do

  desc 'Describe asg by name'
  task :describe_by_name, [:name]  do |t, args|
    asg_cli.desc(args[:name])
  end

  desc 'List asgs'
  task :list do
    asg_cli.list
  end

end