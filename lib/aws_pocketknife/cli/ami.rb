require "thor"
require "aws_pocketknife"

module AwsPocketknife
  module Cli
    class Ami < Thor

      desc "clean AMI_NAME_PATTERN DAYS --dry_run", "Given a name or filter (i.e, test-*), this command will delete all matched AMIs (and associated snapshots) with creation time lower than DAYS."
      option :dry_run, :type => :boolean, :default => true, :desc => 'just show images that would be deleted'
      def clean(ami_name_pattern, days)
        dry_run = options.fetch("dry_run", true)
        AwsPocketknife::Ec2.clean_ami ami_name_pattern: ami_name_pattern,
                                      days: days,
                                      dry_run: dry_run
      end

      desc "share IMAGE_ID ACCOUNT_ID", "share the IMAGE_ID with the specified ACCOUNT_ID"
      def share(image_id, account_id)
        AwsPocketknife::Ec2.share_ami(image_id: image_id, user_id: account_id)
      end

    end
  end
end