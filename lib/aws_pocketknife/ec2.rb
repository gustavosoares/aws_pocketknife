require 'aws_pocketknife'
require 'base64'
require 'openssl'
require 'recursive-open-struct'
require_relative "common/utils"

module AwsPocketknife
  module Ec2

    MAX_ATTEMPTS = 15
    DELAY_SECONDS = 10

    @ec2_client = AwsPocketknife.ec2_client

    class << self
      include AwsPocketknife::Common::Utils

      def create_image(instance_id: "",
                       name: "",
                       description: "",
                       volume_type: "gp2",
                       iops: 3,
                       encrypted: false,
                       volume_size: 60
      )

        resp = @ec2_client.create_image({
                  dry_run: false,
                  instance_id: instance_id, # required
                  name: name, # required
                  description: description,
                  no_reboot: true,
                  block_device_mappings: [
                      {
                          device_name: "/dev/sda1",
                          ebs: {
                              volume_size: volume_size,
                              delete_on_termination: true,
                              volume_type: volume_type, # accepts standard, io1, gp2, sc1, st1
                              iops: iops,
                              encrypted: encrypted,
                          }
                      },
                  ],
              })
        resp.image_id
      end

      def stop_instance_by_id(instance_ids)
        instance_id_list = get_instance_id_list(instance_ids: instance_ids)
        puts "Stoping instance id: #{instance_id_list}"
        resp = @ec2_client.stop_instances({ instance_ids: instance_id_list })
        wait_till_instance_is_stopped(instance_id_list, max_attempts: MAX_ATTEMPTS, delay_seconds: DELAY_SECONDS)
        puts "Stopped ec2 instance #{instance_id_list}"
      end

      def start_instance_by_id(instance_ids)
        instance_id_list = get_instance_id_list(instance_ids: instance_ids)
        puts "Start instance id: #{instance_id_list}"
        resp = @ec2_client.start_instances({ instance_ids: instance_id_list })
      end

      # http://serverfault.com/questions/560337/search-ec2-instance-by-its-name-from-aws-command-line-tool
      def describe_instances_by_name(name: "")
        instances = []
        resp = @ec2_client.describe_instances({dry_run: false,
                                              filters: [
                                                  {
                                                      name: "tag:Name",
                                                      values: [name]
                                                  }
                                              ]})
        resp.reservations.each do |reservation|
          reservation.instances.each do |instance|
            instances << instance
          end
        end
        instances
      end

      def describe_instance_by_id(instance_id: "")
        resp = @ec2_client.describe_instances({dry_run: false, instance_ids: [instance_id.to_s]})
        if resp.nil? or resp.reservations.length == 0 or resp.reservations[0].instances.length == 0
          return nil
        else
          return resp.reservations.first.instances.first
        end
      end

      def get_windows_password(instance_id: "")

        private_keyfile_dir = ENV["AWS_POCKETKNIFE_KEYFILE_DIR"] || ""
        raise "Environment variable AWS_POCKETKNIFE_KEYFILE_DIR is not defined" if private_keyfile_dir.length == 0

        instance = describe_instance_by_id(instance_id: instance_id)
        key_name = instance.key_name
        private_keyfile = File.join(private_keyfile_dir, "#{key_name}.pem")
        raise "File #{private_keyfile} not found" unless File.exist?(private_keyfile)

        resp = @ec2_client.get_password_data({dry_run: false,
                                              instance_id: instance_id})
        encrypted_password = resp.password_data
        decrypted_password = decrypt_windows_password(encrypted_password, private_keyfile)

        RecursiveOpenStruct.new({password: decrypted_password,
                                instance_id: instance.instance_id,
                                 private_ip_address: instance.private_ip_address,
                                 public_ip_address: instance.public_ip_address}, recurse_over_arrays: true)
      end

      private

      # Decrypts an encrypted password using a provided RSA
      # private key file (PEM-format).
      def decrypt_windows_password(encrypted_password, private_keyfile)
        encrypted_password_bytes = Base64.decode64(encrypted_password)
        private_keydata = File.open(private_keyfile, "r").read
        private_key = OpenSSL::PKey::RSA.new(private_keydata)
        private_key.private_decrypt(encrypted_password_bytes)
      end

      def get_instance_id_list(instance_ids: "")
        instance_ids.strip.split(";")
      end

      def wait_till_instance_is_stopped(instance_ids, max_attempts: 12, delay_seconds: 10)
        total_wait_seconds = max_attempts * delay_seconds;
        puts "Waiting up to #{total_wait_seconds} seconds with #{delay_seconds} seconds delay for ec2 instance #{instance_ids} to be stopped"
        @ec2_client.wait_until(:instance_stopped, { instance_ids: instance_ids }) do |w|
          w.max_attempts = max_attempts
          w.delay = delay_seconds
        end
      end

      def wait_till_instance_is_terminated(instance_ids, max_attempts: 12, delay_seconds: 10)
        total_wait_seconds = max_attempts * delay_seconds;
        puts "Waiting up to #{total_wait_seconds} seconds with #{delay_seconds} seconds delay for ec2 instance #{instance_ids} to be terminated"
        @ec2_client.wait_until(:instance_terminated, { instance_ids: instance_ids }) do |w|
          w.max_attempts = max_attempts
          w.delay = delay_seconds
        end
      end

    end

  end
end
