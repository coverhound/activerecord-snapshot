module ActiveRecord
  module Snapshot
    class SelectSnapshot
      def self.call(selected_version = nil)
        if selected_version
          List.get(version: selected_version)
        else
          List.download
          List.last
        end
      end
    end
  end
end
