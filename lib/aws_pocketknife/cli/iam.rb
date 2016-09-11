require "thor"
require "aws_pocketknife"

module AwsPocketknife
  module Cli
    class Iam < Thor

      desc "list_ssl_certs", "list ssl certs"
      def list_ssl_certs
        certs = AwsPocketknife::Iam.list_ssl_certificates
        AwsPocketknife::Iam.nice_print(object: certs.to_h)
      end

      desc "create_user USERNAME", "create user"
      def create_user(username)
        AwsPocketknife::Iam.create_iam_user username
      end

      desc "create_group GROUP_NAME", "create group"
      def create_group(group_name)
        AwsPocketknife::Iam.create_group group_name
      end

      desc "add_user_to_group USERNAME GROUP_NAME", "add user to group"
      def add_user_to_group(username, group_name)
        AwsPocketknife::Iam.add_user_to_group username, group_name
      end

    end
  end
end