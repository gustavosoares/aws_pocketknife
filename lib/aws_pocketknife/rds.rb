require 'aws_pocketknife'

module AwsPocketknife
  module Rds

    AVAILABLE = 'available'.freeze
    CREATING = 'creating'.freeze
    DELETING = 'deleting'.freeze

    class << self
      include AwsPocketknife::Common::Utils

      def describe_snapshots(options)
        db_name = options.fetch(:db_name, '')
        rds_client.describe_db_snapshots({db_instance_identifier: db_name}).db_snapshots
      end

      # creates snapshot for the database name
      def create_snapshot(options)
        db_name = options.fetch(:db_name, 'my-snapshot')
        snapshot_name = get_snapshot_name(db_name)
        rds_client.create_db_snapshot(db_instance_identifier: db_name, db_snapshot_identifier: snapshot_name)

        Retryable.retryable(:tries => 15, :sleep => lambda { |n| 2**n }, :on => StandardError) do |retries, exception|
          response = rds_client.describe_db_snapshots(db_snapshot_identifier: snapshot_name)

          snapshot = response.db_snapshots.find { |s| s.db_snapshot_identifier == snapshot_name }
          status = snapshot.status
          percent_progress = snapshot.percent_progress
          puts "RDS Snapshot #{snapshot_name} status: #{status}, progress #{percent_progress}%"
          raise StandardError if status != AwsPocketknife::Rds::AVAILABLE
        end

      end

      def get_snapshot_name(db_name)
        now_str = Time.now.strftime('%Y-%m-%d-%H-%M')
        "#{db_name}-#{now_str}"
      end

      def clean_snapshots(options)
        puts "options: #{options}"

        db_name = options.fetch(:db_name, '')
        days = options.fetch(:days, '30').to_i * 24 * 3600
        dry_run = options.fetch(:dry_run, true)

        creation_time = Time.now - days
        puts "Cleaning up MANUAL snapshots older than #{days} days, i.e, with creation_time < #{creation_time} for db [#{db_name}]"

        snapshots_to_remove = []
        snapshots = describe_snapshots options
        snapshots.each do |snapshot|
          snapshot.snapshot_create_time.is_a?(String) ? snapshot_creation_time = Time.parse(snapshot.snapshot_create_time) : snapshot_creation_time = snapshot.snapshot_create_time

          msg = "Snapshot #{snapshot.db_snapshot_identifier} (type=#{snapshot.snapshot_type}) (snapshot_creation_time: #{snapshot_creation_time}) > (#{creation_time})? "
          if creation_time <= snapshot_creation_time
            if (snapshot.snapshot_type == 'manual')
              snapshots_to_remove << snapshot
              msg << " YES, marking to be deleted"
            else
              msg << " NO"
            end
          else
            msg << "NO (is not a manual snapshot)"
          end
          puts msg
        end

        puts "snapshots_to_remove: #{snapshots_to_remove.map { |s| s.db_snapshot_identifier}}"

        unless dry_run
          snapshots_to_remove.each do |snapshot|
            puts "Removing snapshot #{snapshot.db_snapshot_identifier} (status=#{snapshot.status})"
            rds_client.delete_db_snapshot({db_snapshot_identifier:snapshot.db_snapshot_identifier})
          end
        end

      end

    end

  end
end
