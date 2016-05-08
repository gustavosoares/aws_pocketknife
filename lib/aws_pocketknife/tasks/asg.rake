require_relative '../asg'

namespace :asg do

  def print_asg(asgs: [])
    headers = ["name", "min size", "max size", "desired capacity", "instances", "elb"]
    data = []
    if asgs.length > 0
      asgs.each do |asg|
        instances = []
        asg.instances.map { |instance| instances << instance.instance_id }
        data << [asg.auto_scaling_group_name, asg.min_size, asg.max_size,
                 asg.desired_capacity, instances.join(", "), asg.load_balancer_names.join(", ")]
      end
      AwsPocketknife::Asg.pretty_table(headers: headers, data: data)
    else
      puts "No asg(s) found for name #{args[:name]}"
    end
  end


  desc 'Describe asg by name'
  task :describe_by_name, [:name]  do |t, args|
    asgs = AwsPocketknife::Asg.describe_asg_by_name(name: args[:name])
    print_asg(asgs: asgs)
  end

  desc 'List asgs'
  task :list do
    asgs = AwsPocketknife::Asg.list
    print_asg(asgs: asgs)
  end

end