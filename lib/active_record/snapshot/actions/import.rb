module ActiveRecord
  module Snapshot
    class Import
      def self.call(*args)
        new(*args).call
      end

      def initialize(version: nil, tables: [])
        version = SelectSnapshot.call(version) if partial_snapshot?(version)
        @snapshot = Snapshot.new(version)
        @tables = tables
      end

      def call
        Stepper.call(self, **steps)
      end

      private

      attr_reader :snapshot, :tables

      def config
        ActiveRecord::Snapshot.config
      end

      def partial_snapshot?(version)
        version.blank? || version.to_i.to_s == version
      end

      def steps
        {
          download: "Download snapshot to #{snapshot.encrypted}",
          decrypt: "Decrypt snapshot to #{snapshot.compressed}",
          decompress: "Decompress snapshot to #{snapshot.dump}",
        }.tap do |s|
          if tables.empty?
            s[:reset_database] = "Reset database"
          else
            s[:filter_tables] = "Filter tables"
          end

          s[:import] = "Importing the snapshot into #{config.db.database}"
        end
      end

      def download
        snapshot.download
      end

      def decrypt
        OpenSSL.decrypt(
          input: snapshot.encrypted,
          output: snapshot.compressed
        )
      end

      def decompress
        Bzip2.decompress(snapshot.dump)
      end

      def reset_database
        Rake::Task["db:drop"].invoke
        Rake::Task["db:create"].invoke
      end

      def filter_tables
        FilterTables.call(tables: tables, sql_dump: snapshot.dump)
      end

      def import
        config.adapter.import(input: snapshot.dump)
        Rake::Task["db:schema:dump"].invoke
      end
    end
  end
end
