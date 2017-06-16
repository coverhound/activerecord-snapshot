module ActiveRecord
  module Snapshot
    class Bzip2
      def self.compress(path)
        return false unless File.file?(path)
        system("nice bzip2 -z #{path}")
      end

      def self.decompress(path)
        return false unless File.file?(path)
        system("nice bunzip2 #{path}")
      end
    end
  end
end
