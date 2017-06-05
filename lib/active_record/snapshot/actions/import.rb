module ActiveRecord
  module Snapshot
    class Import
      def self.call(*args)
        new(*args).call
      end

      def initialize(version: nil, tables: [])
        if partial_snapshot?(version)
          initialize_partial(version)
        else
          initialize_custom(version)
        end
        @tables = tables
      end

      def call
        steps.each { |step, message| Logger.call(message, method(step)) }
      end

      private

      attr_reader :snapshot, :s3, :tables

      def config
        ActiveRecord::Snapshot.config
      end

      def partial_snapshot?(version)
        version.blank? || version.to_i.to_s == version
      end

      def initialize_partial(version)
        @s3 = S3.new(config.s3.paths.partial_snapshots)
        @snapshot = Snapshot.new(SelectSnapshot.call(version.to_i))
      end

      def initialize_custom(version)
        @s3 = S3.new(config.s3.paths.custom_snapshots)
        @snapshot = Snapshot.new(version)
      end

      def steps
        {
          download: "Download snapshot to #{snapshot.encrypted}",
          decrypt: "Decrypt snapshot to #{snapshot.compressed}",
          decompress: "Decompress snapshot to #{snapshot.dump}",
          import: "Importing the snapshot into #{config.db.database}"
        }
      end

      def download
        s3.download_to(file)
      end

      def decrypt
        OpenSSL.decrypt(
          input: snapshot.encrypted,
          output: snapshot.compressed
        )
      end

      def decompress
        Pbzip2.decompress(snapshot.dump)
      end

      def import
        if tables.empty?
          Rake::Task["db:drop"].invoke
          Rake::Task["db:create"].invoke
        else
          FilterTables.call(tables: tables, sql_dump: snapshot.dump)
        end

        config.adapter.import(input: snapshot.dump)
        Rake::Task["db:schema:dump"].invoke
      end
    end
  end
end
