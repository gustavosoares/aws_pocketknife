require "thor"
require "aws_pocketknife"
require "aws_pocketknife/ec2"

module AwsPocketknife
  module Cli
    class Ec2 < Thor

      desc "find_instances_by_name NAME", "find instances by name. (You can filter by adding *) "
      def find_instances_by_name(name)

        instances = AwsPocketknife::Ec2.describe_instances_by_name(name: name)
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
          puts "No instance(s) found for name #{name}"
        end

      end

      desc "describe_instance_by_id INSTANCE_ID", "find instances by id."
      def describe_instance_by_id(instance_id)
        instance = AwsPocketknife::Ec2.describe_instance_by_id(instance_id: instance_id)
        if instance.nil?
          puts "Instance #{instance_id} not found"
        else
          AwsPocketknife::Ec2.nice_print(object: instance.to_h)
        end
      end

      desc "get_windows_password INSTANCE_ID", "get windows password."
      def get_windows_password(instance_id)
        instance = AwsPocketknife::Ec2.get_windows_password(instance_id: instance_id)
        headers = ["instance id", "password", "private ip", "public ip"]
        data = [[instance.instance_id,
                 instance.password,
                 instance.private_ip_address,
                 instance.public_ip_address]]
        AwsPocketknife::Ec2.pretty_table(headers: headers, data: data)
      end

      desc "stop INSTANCE_ID", "stop ec2 instance"
      def stop(instance_id)
        AwsPocketknife::Ec2.stop_instance_by_id(instance_id)
      end

      desc "start INSTANCE_ID", "start ec2 instance"
      def start(instance_id)
        AwsPocketknife::Ec2.start_instance_by_id(instance_id)
      end

    end
  end
end