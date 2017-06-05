module ActiveRecord
  module Snapshot
    class Version
      class << self
        def current
          @current ||= ::File.read(path).to_i
        end

        def next
          current + 1
        end

        def increment
          File.write(path, self.next)
        end

        def path
          ActiveRecord::Snapshot.config.storage.local.join(
            "snapshot_version"
          ).to_s.freeze
        end
      end
    end
  end
end
