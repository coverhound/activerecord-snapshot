module ActiveRecord
  module Snapshot
    class Railtie < ::Rails::Railtie
      rake_tasks do
        load "tasks/active_record/snapshot_tasks.rake"
      end
    end
  end
end
