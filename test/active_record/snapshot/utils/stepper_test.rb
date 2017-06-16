require "test_helper"
require "minitest/spec"

module ActiveRecord::Snapshot
  class StepperTest < ActiveSupport::TestCase
    extend MiniTest::Spec::DSL

    describe "::call" do
      let(:context) do
        Struct.new(:one, :two, :three).new(true, true, true)
      end
      let(:steps) do
        {
          one: "First step",
          two: "Second step",
          three: "Third step"
        }
      end

      describe "when no steps fail" do
        it "executes them all" do
          Logger.expects(call: true).with(steps[:one]).once
          Logger.expects(call: true).with(steps[:two]).once
          Logger.expects(call: true).with(steps[:three]).once

          Stepper.call(context, **steps)
        end
      end

      describe "when a step fails" do
        before do
          context.stubs(two: false)
        end

        it "aborts" do
          Logger.expects(call: true).with(steps[:one]).once
          Logger.expects(call: false).with(steps[:two]).once
          Logger.expects(:call).with(steps[:three]).never

          assert_raises(SystemExit) do
            Stepper.call(context, **steps)
          end
        end
      end
    end
  end
end
