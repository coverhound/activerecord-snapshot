require_relative "logger"

module ActiveRecord
  module Snapshot
    class Stepper
      def self.call(context, **steps)
        steps.each do |step, message|
          Logger.call(message, &context.method(step)) || abort
        end
      end
    end
  end
end
