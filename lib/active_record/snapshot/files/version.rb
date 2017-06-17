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

        def upload
          S3.new(directory: config.s3.paths.snapshots).upload(path)
        end

        def filename
          "snapshot_version".freeze
        end

        def path
          config.store.local.join(filename).to_s.freeze
        end

        private

        def config
          ActiveRecord::Snapshot.config
        end
      end
    end
  end
end
