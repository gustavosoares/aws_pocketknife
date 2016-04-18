require "bundler/gem_tasks"
require "rspec/core/rake_task"

load "lib/aws_pocketknife/tasks/route53.rake"
load "lib/aws_pocketknife/tasks/ec2.rake"
load "lib/aws_pocketknife/tasks/iam.rake"

RSpec::Core::RakeTask.new(:spec)

desc 'Run tests'
task :test do
  puts "running rspec tests"
  all_good = system("bundle exec rspec spec --format documentation --color --tty")
  if all_good
    exit 0
  else
    exit 1
  end
end

task :default => :test