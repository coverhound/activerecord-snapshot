module ActiveRecord
  module Snapshot
    class Snapshot
      def initialize(filename = nil)
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

      private

      def clean(filename)
        filename.sub(/(\.sql)?(\.bz2)?(\.enc)?$/, ".sql")
      end

      def dump_file
        ActiveRecord::Snapshot.config.storage.local.join(
          "snapshot_#{timestamp}.sql"
        ).to_s
      end

      def timestamp
        Time.new.strftime("%Y-%m-%d_%H-%M-%S")
      end
    end
  end
end
