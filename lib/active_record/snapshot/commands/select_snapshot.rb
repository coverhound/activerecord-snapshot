module ActiveRecord
  module Snapshot
    class SelectSnapshot
      def self.call(*args)
        new(*args).call
      end

      def initialize(selected_version)
        @selected_version = selected_version || latest_version
        @s3 = S3.new("snapshots")
      end

      attr_reader :selected_version, :s3

      def call
        list.each_line do |line|
          version, filename = line.split(" ")
          return filename if version.to_i == selected_version
        end
      end

      private

      def latest_version
        s3.read(Version.path).to_i
      end

      def list
        s3.read(List.path)
      end
    end
  end
end
