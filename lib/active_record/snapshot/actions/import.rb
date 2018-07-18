module ActiveRecord
  module Snapshot
    class Import
      def self.call(*args)
        new(*args).call
      end

      def initialize(version: nil, tables: [])
        @version = version
        if named_version?
          name = version
        else
          @version, name = SelectSnapshot.call(version)
        end
        @snapshot = Snapshot.new(name)
        @tables = tables
      end

      def call
        Stepper.call(self, **steps)
      end

      private

      attr_reader :snapshot, :tables, :version

      def config
        ActiveRecord::Snapshot.config
      end

      def named_version?
        !version.blank? && version.to_i.to_s != version.to_s
      end

      def version_downloaded?
        version.to_i == Version.current && File.file?(snapshot.dump)
      end

      def steps
        steps = {}
        unless version_downloaded?
          steps[:download] = "Download snapshot to #{snapshot.encrypted}"
          steps[:decrypt] = "Decrypt snapshot to #{snapshot.compressed}"
          steps[:decompress] = "Decompress snapshot to #{snapshot.dump}"
        end

        if tables.empty?
          steps[:reset_database] = "Reset database"
        else
          steps[:filter_tables] = "Filter tables"
        end

        steps[:import] = "Importing the snapshot into #{config.db.database}"
        steps[:save] = "Caching the new snapshot version" unless named_version? || tables.present?
        steps[:set_env] = "Setting database environment to #{Rails.env}"
        steps
      end

      def download
        snapshot.download
      end

      def decrypt
        OpenSSL.decrypt(
          input: snapshot.encrypted,
          output: snapshot.compressed
        ) && FileUtils.rm(snapshot.encrypted)
      end

      def decompress
        Bzip2.decompress(snapshot.compressed)
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

      def set_env
        Rake::Task["db:environment:set"].invoke
      end

      def save
        Version.write(version)
      end
    end
  end
end
