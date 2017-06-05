module ActiveRecord
  module Snapshot
    class Pbzip2
      def self.compress(input)
        system("pbzip2 -z #{input}")
      end

      def self.decompress(input)
        system("nice bunzip2 #{input}")
      end
    end
  end
end
