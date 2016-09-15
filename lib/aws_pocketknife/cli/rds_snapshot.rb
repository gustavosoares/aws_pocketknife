require "thor"
require "aws_pocketknife"

module AwsPocketknife
  module Cli
    class RdsSnapshot < Thor

      desc "list_snapshots DB_NAME", "list snapshots"
      def list(db_name)
        snapshots = AwsPocketknife::Rds.describe_snapshots(db_name: db_name)
        headers = [ 'Name', 'Creation Time', 'Type', 'Engine Version']
        data = []
        snapshots.each do |h|
          data << [h.db_snapshot_identifier,
                   h.snapshot_create_time,
                   h.snapshot_type,
                   h.engine_version]
        end
        AwsPocketknife::Rds.pretty_table(headers: headers, data: data)
      end

      desc "clean DB_NAME DAYS --dry_run", "Delete snapshots with creation time lower than DAYS for database_name."
      option :dry_run, :type => :boolean, :default => true, :desc => 'just show images that would be deleted'
      def clean(db_name, days)
        dry_run = options.fetch(:dry_run, true)
        AwsPocketknife::Rds.clean_snapshots db_name: db_name,
                                      days: days,
                                      dry_run: dry_run
      end

    end
  end
end