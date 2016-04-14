require "bundler/gem_tasks"
require "rspec/core/rake_task"

load "lib/aws_pocketknife/tasks/route53.rake"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec
