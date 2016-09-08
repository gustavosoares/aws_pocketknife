require_relative "../elastic_beanstalk"

require_relative '../cli/eb'

eb_cli = AwsPocketknife::Cli::Eb.new

namespace :eb do

  desc "describe_environment_resources"
  task :describe_environment, [:environment_name] do |t, args|
    eb_cli.desc_env(args[:environment_name])
  end

  desc "list environments"
  task :list_environments do
    eb_cli.list_env
  end

  desc "list environment variables for an environment"
  task :list_environment_variables, [:environment_name] do |t, args|
    eb_cli.list_env_variables(args[:environment_name])
  end

end

