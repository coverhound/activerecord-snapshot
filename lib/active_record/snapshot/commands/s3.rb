require 'fog/aws'

module ActiveRecord
  module Snapshot
    class S3
      def initialize(directory:)
        @connection = create_connection
        @directory = directory
      end

      def upload(path)
        connection.put_object(config.bucket, aws_key(path), File.open(path))
      end

      def download_to(path)
        File.open(path, "wb") { |f| f.write(read(path)) }
      end

      def read(path)
        connection.get_object(config.bucket, aws_key(path)).body
      end

      private

      attr_reader :connection, :directory

      def config
        ActiveRecord::Snapshot.config.s3
      end

      def aws_key(path)
        File.join(directory, File.basename(path))
      end

      def create_connection
        ::Fog::Storage.new(
          provider: "AWS",
          region: config.region,
          use_iam_profile: true
        )
      end
    end
  end
end
