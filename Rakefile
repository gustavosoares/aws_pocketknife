require "bundler/gem_tasks"

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