require "test_helper"
require "minitest/spec"

module ActiveRecord::Snapshot
  class SelectSnapshotTest < ActiveSupport::TestCase
    extend MiniTest::Spec::DSL

    describe "::call" do
      subject { SelectSnapshot }
      let(:version) {}

      describe "given a version" do
        let(:version) { 123 }

        it "gets that version from the list" do
          List.expects(:get).with(version: version).once
          subject.call(version)
        end
      end

      describe "given no arguments" do
        it "gets the latest version" do
          List.expects(:download).once
          List.expects(:last).once
          subject.call(version)
        end
      end
    end
  end
end
