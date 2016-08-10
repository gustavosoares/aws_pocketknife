require_relative '../ec2'

namespace :ec2 do

  desc 'share ami'
  task :share_ami, [:image_id, :user_id]  do |t, args|
    AwsPocketknife::Ec2.share_ami(image_id: args[:instance_id], user_id: args[:instance_id])
  end

  desc 'bake ami'
  task :bake_ami, [:image_id, :name, :description]  do |t, args|
    instance_id = args[:instance_id]
    name = args[:name]
    description = args[:description]
    image_id = AwsPocketknife::Ec2.create_image(instance_id: instance_id, name: name, description: description)
    puts "image_id: #{image_id}"
  end

  desc 'Stop instance by id'
  task :stop_by_id, [:instance_id]  do |t, args|
    AwsPocketknife::Ec2.stop_instance_by_id(args[:instance_id])
  end

  desc 'Start instance by id'
  task :start_by_id, [:instance_id]  do |t, args|
    AwsPocketknife::Ec2.start_instance_by_id(args[:instance_id])
  end

  desc 'Describe instance by id'
  task :describe_instance_by_id, [:instance_id]  do |t, args|
    instance = AwsPocketknife::Ec2.describe_instance_by_id(instance_id: args[:instance_id])
    if instance.nil?
      puts "Instance #{args[:instance_id]} not found"
    else
      AwsPocketknife::Ec2.nice_print(object: instance.to_h)
    end
  end

  desc 'Describe instance by name'
  task :describe_instance_by_name, [:name]  do |t, args|
    instances = AwsPocketknife::Ec2.describe_instances_by_name(name: args[:name])
    headers = ["name", "id", "image", "state", "private ip", "public ip", "type", "key name", "launch time"]
    data = []
    if instances.length > 0
      instances.each do |instance|
        name = AwsPocketknife::Ec2.get_tag_value(tags: instance.tags, tag_key: "Name")
        data << [name, instance.instance_id, instance.image_id, instance.state.name,
                 instance.private_ip_address, instance.public_ip_address, instance.instance_type,
                instance.key_name, instance.launch_time]
      end
      AwsPocketknife::Ec2.pretty_table(headers: headers, data: data)
    else
      puts "No instance(s) found for name #{args[:name]}"
    end
  end

  desc 'Find instances by name'
  task :find_instances_by_name, [:name]  do |t, args|
    Rake::Task["ec2:describe_instance_by_name"].invoke(args[:name])
  end

  desc 'Get windows password'
  task :get_windows_password, [:instance_id]  do |t, args|
    instance = AwsPocketknife::Ec2.get_windows_password(instance_id: args[:instance_id])
    headers = ["instance id", "password", "private ip", "public ip"]
    data = [[instance.instance_id,
            instance.password,
            instance.private_ip_address,
            instance.public_ip_address]]
    AwsPocketknife::Ec2.pretty_table(headers: headers, data: data)
  end

end