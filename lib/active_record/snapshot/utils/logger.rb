module ActiveRecord
  module Snapshot
    class Logger
      def self.call(*args, &block)
        new(*args, &block).call
      end

      def initialize(step)
        @step = step
      end

      def call
        start
        yield ? finish : failed
      end

      def start
        puts "== Running: #{step}"
      end

      def finish
        puts "== Done"
      end

      def failed
        abort "== Failed: #{step}"
      end
    end
  end
end
