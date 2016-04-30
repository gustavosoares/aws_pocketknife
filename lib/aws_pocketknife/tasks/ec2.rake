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

  desc 'Describe instance by name'
  task :describe_instance_by_name, [:name]  do |t, args|
    instances = AwsPocketknife::Ec2.describe_instances_by_name(name: args[:name])
    headers = ["name", "id", "image", "state", "private ip", "public ip", "key name", "launch time"]
    data = []
    if instances.length > 0
      instances.each do |instance|
        name = AwsPocketknife::Ec2.get_tag_value(tags: instance.tags, tag_key: "Name")
        data << [name, instance.instance_id, instance.image_id, instance.state.name,
                 instance.private_ip_address, instance.public_ip_address, instance.key_name,
                instance.launch_time]
      end
      AwsPocketknife::Ec2.pretty_table(headers: headers, data: data)
    else
      puts "No instance(s) found for name #{args[:name]}"
    end
  end

end