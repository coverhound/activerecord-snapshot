module ActiveRecord
  module Snapshot
    class Snapshot
      def initialize(filename = nil)
        directory = filename ? paths.named_snapshots : paths.snapshots
        @s3 = S3.new(directory: directory)
        @filename = clean(filename) || dump_file
      end

      def dump
        @filename
      end

      def compressed
        @filename + ".bz2"
      end

      def encrypted
        compressed + ".enc"
      end

      def upload
        s3.upload(encrypted)
      end

      def download
        s3.download_to(encrypted)
      end

      private

      attr_reader :s3

      def paths
        ActiveRecord::Snapshot.config.s3.paths
      end

      def clean(filename)
        filename&.sub(/(\.sql)?(\.bz2)?(\.enc)?$/, ".sql")
      end

      def dump_file
        ActiveRecord::Snapshot.config.store.local.join(
          "snapshot_#{timestamp}.sql"
        )
      end

      def timestamp
        Time.zone.now.strftime("%Y-%m-%d_%H-%M-%S")
      end
    end
  end
end
