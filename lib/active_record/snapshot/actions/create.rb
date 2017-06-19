require "active_record/snapshot/utils/logger"

module ActiveRecord
  module Snapshot
    class Create
      def self.call(*args)
        new(*args).call
      end

      def initialize(name: nil)
        @named_snapshot = !name.nil?
        @snapshot = Snapshot.new(name)
      end

      def call
        Stepper.call(self, **steps)
      end

      private

      attr_reader :snapshot, :named_snapshot

      def config
        ActiveRecord::Snapshot.config
      end

      def steps
        {
          dump: "Create dump of #{config.db.database} at #{snapshot.dump}",
          compress: "Compress snapshot to #{snapshot.compressed}",
          encrypt: "Encrypt snapshot to #{snapshot.encrypted}",
          upload_snapshot: "Upload files to #{config.s3.bucket}"
        }.tap do |s|
          next if named_snapshot
          s[:update_list] = "Update list from #{Version.current} to #{Version.next} with #{snapshot.encrypted}"
          s[:upload_version_info] = "Upload version info to #{config.s3.bucket}"
        end
      end

      def dump
        config.adapter.dump(tables: config.tables, output: snapshot.dump)
      end

      def compress
        Bzip2.compress(snapshot.dump)
      end

      def encrypt
        OpenSSL.encrypt(
          input: snapshot.compressed,
          output: snapshot.encrypted
        )
      end

      def update_list
        Version.increment
        List.add(version: Version.current, file: snapshot.encrypted)
      end

      def upload_snapshot
        snapshot.upload
      end

      def upload_version_info
        Version.upload
        List.upload
      end
    end
  end
end
