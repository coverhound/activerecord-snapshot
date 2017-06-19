module ActiveRecord
  module Snapshot
    class SelectSnapshot
      def self.call(selected_version = nil)
        if selected_version.blank?
          List.download
          List.last
        else
          List.get(version: selected_version)
        end
      end
    end
  end
end
