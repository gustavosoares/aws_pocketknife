require 'aws_pocketknife'

module AwsPocketknife
  module Ec2

    MAX_ATTEMPTS = 15
    DELAY_SECONDS = 10

    @ec2_client = AwsPocketknife.ec2_client

    class << self

      def stop_instance_by_id(instance_id)
        puts "Stoping instance id: #{instance_id}"
        resp = @ec2_client.stop_instances({ instance_ids: [instance_id.to_s] })
        wait_till_instance_is_stopped(instance_id, max_attempts: MAX_ATTEMPTS, delay_seconds: DELAY_SECONDS)
        puts "Stopped ec2 instance #{instance_id}"
      end

      def start_instance_by_id(instance_id)
        puts "Start instance id: #{instance_id}"
        resp = @ec2_client.start_instances({ instance_ids: [instance_id.to_s] })

      end

      def describe_instance_by_id(instance_id)
        puts "Getting ec2 instance #{instance_id}"
        resp = @ec2_client.describe_instances({dry_run: false, instance_ids: [instance_id.to_s]})
        if resp.nil? or resp.reservations.length == 0
          raise "Could not describe ec2 instance #{instance_id}"
        end
        resp.reservations.first.instances.first
      end

      def get_instance_status(instance_id)
        puts "Getting ec2 instance status for instance id #{instance_id}"

        resp = @ec2_client.describe_instance_status({
                               dry_run: false,
                               instance_ids: [instance_id.to_s],
                               include_all_instances: true
                           })

        if resp.instance_statuses.length == 0
          raise "Could not get instance state information for ec2 instance #{instance_id}"
        end

        resp.instance_statuses.first
      end

      private

      def get_instance_state(instance_id)
        get_instance_status(instance_id).instance_state
      end

      def wait_till_instance_is_stopped(instance_id, max_attempts: 12, delay_seconds: 10)
        total_wait_seconds = max_attempts * delay_seconds;
        puts "Waiting up to #{total_wait_seconds} seconds with #{delay_seconds} seconds delay for ec2 instance #{instance_id} to be stopped"
        @ec2_client.wait_until(:instance_stopped, { instance_ids: [instance_id.to_s] }) do |w|
          w.max_attempts = max_attempts
          w.delay = delay_seconds
        end
      end

      def wait_till_instance_is_terminated(instance_id, max_attempts: 12, delay_seconds: 10)
        total_wait_seconds = max_attempts * delay_seconds;
        puts "Waiting up to #{total_wait_seconds} seconds with #{delay_seconds} seconds delay for ec2 instance #{instance_id} to be terminated"
        @ec2_client.wait_until(:instance_terminated, { instance_ids: [instance_id.to_s] }) do |w|
          w.max_attempts = max_attempts
          w.delay = delay_seconds
        end
      end

    end

  end
end
