require "test_helper"
require "minitest/spec"

module ActiveRecord::Snapshot
  class ListTest < ActiveSupport::TestCase
    extend MiniTest::Spec::DSL

    subject { Version }
    let(:file) { Tempfile.new }
    after do
      file.unlink
    end

    describe "::current" do
      let(:version) { 322 }
      before do
        subject.stubs(path: file.path)
        File.write(file, version)
      end

      it "gets the current version" do
        assert_equal version, subject.current
      end
    end

    describe "::increment" do
      let(:version) { 322 }
      before do
        subject.stubs(path: file.path)
        File.write(file, version)
      end

      it "writes the next version to the file" do
        subject.increment
        assert_equal version + 1, subject.current
      end
    end

    describe "::upload" do
      it "uploads to the path" do
        S3.any_instance.expects(:upload).with(subject.path)
        subject.upload
      end
    end
  end
end
