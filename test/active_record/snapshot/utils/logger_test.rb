require "test_helper"
require "minitest/spec"

module ActiveRecord::Snapshot
  class LoggerTest < ActiveSupport::TestCase
    extend MiniTest::Spec::DSL

    describe "::call" do
      let(:step) { "Download snapshot" }
      describe "when the block succeds" do
        it "says it's done" do
          assert_output("== Running: #{step}\n== Done\n") do
            Logger.call(step) { true }
          end
        end
      end

      describe "when the block fails" do
        it "prints an error stderr" do
          assert_output("== Running: #{step}\n", "== Failed: #{step}\n") do
            Logger.call(step) { false }
          end
        end
      end
    end
  end
end
