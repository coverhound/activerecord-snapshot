module ActiveRecord
  module Snapshot
    class Logger
      def self.call(*args, &block)
        new(*args).call(&block)
      end

      def initialize(step)
        @step = step
      end

      def call
        start
        yield.tap do |success|
          success ? finish : failed
        end
      end

      def start
        puts "== Running: #{@step}"
      end

      def finish
        puts "== Done"
      end

      def failed
        $stderr.puts "== Failed: #{@step}"
      end
    end
  end
end
