require_relative "../cloudwatch_logs"

namespace :cloudwatch do

  namespace :logs do
    desc "Create log group"
    task :create_group, [:name] do |t, args|
      AwsPocketknife::CloudwatchLogs.create_log_group(log_group_name: args[:name])
    end
  end

end
