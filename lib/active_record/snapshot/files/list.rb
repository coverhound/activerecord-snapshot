module ActiveRecord
  module Snapshot
    class List
      class << self
        def add(current)
        end

        def path
          ActiveRecord::Snapshot.config.storage.local.join(
            "snapshot_list"
          ).to_s.freeze
        end
      end
    end
  end
end
