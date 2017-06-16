module ActiveRecord
  module Snapshot
    class Version
      class << self
        def current
          ::File.read(path).to_i
        end

        def next
          current + 1
        end

        def increment
          File.write(path, self.next)
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
