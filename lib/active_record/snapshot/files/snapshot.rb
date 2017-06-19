module ActiveRecord
  module Snapshot
    class Snapshot
      def initialize(filename = nil)
        @filename = clean(filename) || dump_file
        directory = named? ? paths.named_snapshots : paths.snapshots
        @s3 = S3.new(directory: directory)
      end

      def named?
        /\Asnapshot_\d{4}-\d{2}-\d{2}_\d{2}-\d{2}-\d{2}(\..+)?\z/ !~ File.basename(@filename)
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
        return unless filename
        basename = File.basename(
          filename.sub(/(\.sql)?(\.bz2)?(\.enc)?$/, ".sql")
        )
        local_path.join(basename).to_s
      end

      def dump_file
        local_path.join("snapshot_#{timestamp}.sql").to_s
      end

      def local_path
        ActiveRecord::Snapshot.config.store.local
      end

      def timestamp
        Time.zone.now.strftime("%Y-%m-%d_%H-%M-%S")
      end
    end
  end
end
