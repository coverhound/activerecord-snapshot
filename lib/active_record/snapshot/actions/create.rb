require "active_record/snapshot/utils/logger"

module ActiveRecord
  module Snapshot
    class Create
      def self.call(*args)
        new(*args).call
      end

      def initialize(name: nil)
        @snapshot = ActiveRecord::Snapshot::Snapshot.new(name)
        paths = config.s3.paths
        directory = name ? paths.custom_snapshots : paths.partial_snapshots
        @s3 = S3.new(directory)
      end

      def call
        steps.each { |step, message| Logger.call(message, method(step)) }
      end

      private

      attr_reader :snapshot, :s3

      def config
        ActiveRecord::Snapshot.config
      end

      def run(message, &block)
        Logger.call(message, &block)
      end

      def steps
        {
          dump: "Create dump of #{config.db.database} at #{snapshot.dump}",
          compress: "Compress snapshot to #{snapshot.compressed}",
          encrypt: "Encrypt snapshot to #{snapshot.encrypted}",
          update_list: "Update list from #{Version.current} to #{Version.next} with #{snapshot.encrypted}",
          upload_snapshots: "Upload files to #{config.s3.bucket}"
        }
      end

      def dump
        config.adapter.dump(tables: config.tables, output: snapshot.dump)
      end

      def compress
        Pbzip2.compress(snapshot.dump)
      end

      def encrypt
        OpenSSL.encrypt(
          input: snapshot.compressed,
          output: snapshot.encrypted,
        )
      end

      def update_list
        Version.increment
      end

      def upload_snapshots
        s3.upload(snapshot.encrypted)
        s3.upload(Version.path)
        s3.upload(List.path)
      end
    end
  end
end
