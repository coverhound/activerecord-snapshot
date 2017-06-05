require 'fog'

module ActiveRecord
  module Snapshot
    class S3
      def initialize(directory:)
        @connection = create_connection
        @directory = directory
      end

      def upload(file)
        connection.put_object(config.bucket, aws_key(file), File.open(file))
      end

      def download_to(file)
        File.open(file, "wb") { |f| f.write(read(file)) }
      end

      def read(file)
        connect.get_object(config.bucket, aws_key(file)).body
      end

      private

      attr_reader :connection, :directory

      def config
        ActiveRecord::Snapshot.config.s3
      end

      def aws_key(file)
        File.join(directory, File.basename(file))
      end

      def create_connection
        ::Fog::Storage.new(
          provider: "AWS",
          region: config.region,
          aws_access_key_id: config.access_key_id,
          aws_secret_access_key: config.secret_access_key
        )
      end
    end
  end
end
