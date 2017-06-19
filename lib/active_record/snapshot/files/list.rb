module ActiveRecord
  module Snapshot
    class List
      class << self
        def download
          s3.download_to(path)
        end

        def upload
          s3.upload(path)
        end

        def add(version:, file:)
          contents = File.read(path)
          File.open(path, "w") do |f|
            f.puts "#{version.to_i} #{File.basename(file)}"
            f.write contents
          end
        end

        def get(version:)
          File.readlines(path).each do |line|
            version_str, filename = line.split(" ")
            return [version_str.to_i, filename] if version_str.to_i == version.to_i
          end
          []
        end

        def last
          version_str, filename = File.open(path, &:readline).split(" ")
          [version_str.to_i, filename]
        end

        def filename
          "snapshot_list".freeze
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
