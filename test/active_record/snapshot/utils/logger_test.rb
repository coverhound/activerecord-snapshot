require "test_helper"
require "minitest/spec"

module ActiveRecord::Snapshot
  class LoggerTest < ActiveSupport::TestCase
    extend MiniTest::Spec::DSL

    describe "::call" do
      let(:step) { "Download snapshot" }
      before do
        @old_stdout = $stdout
        @old_stderr = $stderr
        @output = StringIO.new
        $stdout = @output
        $stderr = @output
      end

      after do
        $stdout = @old_stdout
        $stderr = @old_stdout
      end

      describe "when the block succeds" do
        it "says it's done" do
          Logger.call(step) { true }
          assert_equal "== Running: #{step}\n== Done\n", @output.string
        end
      end

      describe "when the block fails" do
        it "prints an error stderr" do
          Logger.call(step) { false }
          assert_equal "== Running: #{step}\n== Failed: #{step}\n", @output.string
        end
      end
    end
  end
end
