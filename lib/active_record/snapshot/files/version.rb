module ActiveRecord
  module Snapshot
    class Version
      class << self
        def current
          return nil unless File.file?(path)
          ::File.read(path).to_i
        end

        def next
          current + 1
        end

        def increment
          File.write(path, self.next)
        end

        def write(version)
          return false unless version.to_i.to_s == version.to_s
          File.write(path, version)
        end

        def download
          s3.download_to(path)
        end

        def upload
          s3.upload(path)
        end

        def filename
          "snapshot_version".freeze
        end

        def path
          config.store.local.join(filename).to_s.freeze
        end

        private

        def s3
          S3.new(directory: config.s3.paths.snapshots)
        end

        def config
          ActiveRecord::Snapshot.config
        end
      end
    end
  end
end
