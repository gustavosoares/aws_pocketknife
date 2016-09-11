require 'aws_pocketknife'
require 'base64'
require 'openssl'
require 'retryable'
require 'recursive-open-struct'
require_relative "common/utils"
require_relative "common/logging"

module AwsPocketknife
  module Ec2

    MAX_ATTEMPTS = 15
    DELAY_SECONDS = 10

    STATE_PENDING = 'pending'
    STATE_AVAILABLE = 'available'
    STATE_DEREGISTERED = 'deregistered'
    STATE_INVALID = 'invalid'
    STATE_FAILED = 'failed'
    STATE_ERROR = 'error'

    class << self
      include AwsPocketknife::Common::Utils
      #include AwsPocketknife::Common::Logging

      Logging = Common::Logging

      def find_ami_by_name(name: '')
        ec2_client.describe_images({dry_run: false,
                                    filters: [
                                        {
                                            name: "tag:Name",
                                            values: [name]
                                        }
                                    ]}).images
      end

      def find_ami_by_id(id: '')
        ec2_client.describe_images({dry_run: false,
                                    image_ids: [id]}).images.first
      end

      def delete_ami_by_id(id: '')
        image = find_ami_by_id(id: id)
        snapshot_ids = snapshot_ids(image)
        ec2_client.deregister_image(image_id: id)

        Retryable.retryable(:tries => 20, :sleep => lambda { |n| 2**n }, :on => StandardError) do |retries, exception|
          image = find_ami_by_id(id: id)
          message =  "retry #{retries} - Deleting image #{id}"
          message << " State: #{image.state}" if image
          puts message
          raise StandardError unless image.nil?
        end

        delete_snapshots(snapshot_ids: snapshot_ids)
        #aws_helper_ec2_client.image_delete(id)
      end

      def delete_snapshots(snapshot_ids: [])
        snapshot_ids.each do |snapshot_id|
          puts "Deleting Snapshot: #{snapshot_id}"
          ec2_client.delete_snapshot(snapshot_id: snapshot_id)
        end
      end

      def snapshot_ids(image)
        snapshot_ids = []
        image.block_device_mappings.each do |device_mapping|
          ebs = device_mapping.ebs
          snapshot_ids << ebs.snapshot_id if ebs && !ebs.snapshot_id.to_s.empty?
        end
        snapshot_ids
      end

      def clean_ami(options)
        puts "options: #{options}"

        dry_run = options.fetch(:dry_run, true)
        image_ids = find_ami_by_creation_time(options)
        images_to_delete = find_unused_ami(image_ids: image_ids)

        puts "images (#{image_ids.length}): #{image_ids}"
        puts "images to delete (#{images_to_delete.length}): #{images_to_delete}"

        unless dry_run
          images_to_delete.each do |image_id|
            puts "deleting image #{image_id}"
            delete_ami_by_id(id: image_id)
          end
        end

      end

      def find_unused_ami(image_ids: [])
        images_to_delete = []
        image_ids.each do |image_id|
          # check if there is any instance using the image id
          instances = describe_instances_by_image_id(image_id_list: [image_id])
          if instances.empty?
            images_to_delete << image_id
          else
            puts "#{image_id} is used by #{instances.map { |instance| instance.instance_id }}"
          end
          Kernel.sleep 2
        end
        return images_to_delete
      end

      def find_ami_by_creation_time(options)

        days = options.fetch(:days, '30').to_i * 24 * 3600
        creation_time = Time.now-days
        puts "Cleaning up images older than #{days} days (creation_time=#{creation_time})"

        image_ids = []
        images = find_ami_by_name(name: options.fetch(:ami_name_pattern, ''))
        images.each do |image|
          image_creation_time = Time.parse(image.creation_date)
          if creation_time <= image_creation_time
            image_ids << image.image_id
          else
            puts "image #{image.image_id} (creation_time: #{image_creation_time}) WILL NOT be deleted"
          end
        end
        return image_ids
      end

      def share_ami(image_id: '', user_id: '', options: {})
        begin
          options = {}
          options[:image_id] = image_id
          options[:launch_permission] = create_launch_permission(user_id)
          log.info "Sharing Image #{image_id} with #{user_id} with options #{options}"
          response = @ec2_client.modify_image_attribute(options=options)
          return response
        rescue Exception => e
          log.info "## Got an error when sharing the image... #{e.cause} -> #{e.message}"
          raise
        end
      end


      def create_image(instance_id: "", name: "", description: "Created at #{Time.now}",
                       timeout: 1800, publish_to_account: "",
                       volume_type: "gp2",
                       iops: 3,
                       encrypted: false,
                       volume_size: 60
      )

        begin
          Logging.logger.info "creating image"
          instance = find_by_id(instance_id: instance_id)
          instance = ec2.instances[instance_id]
          image = instance.create_image(name, :description => description)
          sleep 2 until image.exists?
          Logging.logger.info "image #{image.id} state: #{image.state}"
          sleep 10 until image.state != :pending
          if image.state == :failed
            raise "Create image failed"
          end
          Logging.logger.info "image created"
        rescue => e
          Logging.logger.error "Creating AMI failed #{e.message}"
          Logging.logger.error e.backtrace.join("\n")
          raise e
        end
        if publish_to_account.length != 0
          Logging.logger.info "add permissions for #{publish_to_account}"
          image.permissions.add(publish_to_account.gsub(/-/, ''))
        end
        image.id.tap do |image_id|
          Logging.logger.info "Image #{@name}[#{image_id}] created"
          return image_id
        end
      end

      def stop_instance_by_id(instance_ids)
        instance_id_list = get_instance_id_list(instance_ids: instance_ids)
        Logging.logger.info "Stoping instance id: #{instance_id_list}"
        resp = ec2_client.stop_instances({ instance_ids: instance_id_list })
        wait_till_instance_is_stopped(instance_id_list, max_attempts: MAX_ATTEMPTS, delay_seconds: DELAY_SECONDS)
        Logging.logger.info "Stopped ec2 instance #{instance_id_list}"
      end

      def start_instance_by_id(instance_ids)
        instance_id_list = get_instance_id_list(instance_ids: instance_ids)
        Logging.logger.info "Start instance id: #{instance_id_list}"
        ec2_client.start_instances({ instance_ids: instance_id_list })
      end

      # http://serverfault.com/questions/560337/search-ec2-instance-by-its-name-from-aws-command-line-tool
      def find_by_name(name: "")
        instances = []
        resp = ec2_client.describe_instances({dry_run: false,
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

      def describe_instances_by_image_id(image_id_list: [])
        instances = []
        resp = ec2_client.describe_instances({dry_run: false,
                                               filters: [
                                                   {
                                                       name: "image-id",
                                                       values: image_id_list
                                                   }
                                               ]})
        resp.reservations.each do |reservation|
          reservation.instances.each do |instance|
            instances << instance
          end
        end
        instances
      end

      def find_by_id(instance_id: "")
        resp = ec2_client.describe_instances({dry_run: false, instance_ids: [instance_id.to_s]})
        if resp.nil? or resp.reservations.length == 0 or resp.reservations[0].instances.length == 0
          return nil
        else
          return resp.reservations.first.instances.first
        end
      end

      def get_windows_password(instance_id: "")

        private_keyfile_dir = ENV["AWS_POCKETKNIFE_KEYFILE_DIR"] || ""
        raise "Environment variable AWS_POCKETKNIFE_KEYFILE_DIR is not defined" if private_keyfile_dir.length == 0

        instance = find_by_id(instance_id: instance_id)
        key_name = instance.key_name
        private_keyfile = File.join(private_keyfile_dir, "#{key_name}.pem")
        raise "File #{private_keyfile} not found" unless File.exist?(private_keyfile)

        resp = ec2_client.get_password_data({dry_run: false,
                                              instance_id: instance_id})
        encrypted_password = resp.password_data
        decrypted_password = decrypt_windows_password(encrypted_password, private_keyfile)

        RecursiveOpenStruct.new({password: decrypted_password,
                                instance_id: instance.instance_id,
                                 private_ip_address: instance.private_ip_address,
                                 public_ip_address: instance.public_ip_address}, recurse_over_arrays: true)
      end

      # def ec2
      #   @ec2 ||= Aws::EC2.new(:ec2_endpoint => "ec2.#{AwsPocketknife::AWS_REGION}.amazonaws.com")
      # end

      private

      def create_launch_permission(user_id)
        {
            add: [
                {
                    user_id: user_id
                },
            ]
        }
      end

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
        Logging.logger.info "Waiting up to #{total_wait_seconds} seconds with #{delay_seconds} seconds delay for ec2 instance #{instance_ids} to be stopped"
        ec2_client.wait_until(:instance_stopped, { instance_ids: instance_ids }) do |w|
          w.max_attempts = max_attempts
          w.delay = delay_seconds
        end
      end

      def wait_till_instance_is_terminated(instance_ids, max_attempts: 12, delay_seconds: 10)
        total_wait_seconds = max_attempts * delay_seconds;
        Logging.logger.info "Waiting up to #{total_wait_seconds} seconds with #{delay_seconds} seconds delay for ec2 instance #{instance_ids} to be terminated"
        ec2_client.wait_until(:instance_terminated, { instance_ids: instance_ids }) do |w|
          w.max_attempts = max_attempts
          w.delay = delay_seconds
        end
      end

    end

  end
end
