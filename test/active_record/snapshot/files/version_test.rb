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

      it "returns nil if there is no version file" do
        subject.stubs(path: "asdf")
        assert_nil subject.current
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

    describe "::write" do
      let(:version) { 952 }
      before do
        subject.stubs(path: file.path)
      end

      it "returns false when given a non-integer" do
        assert_equal false, subject.write("foo2")
      end

      it "writes the version to the file" do
        subject.write(version)
        assert_equal version, subject.current
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
