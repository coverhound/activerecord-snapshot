require "test_helper"
require "minitest/spec"

module ActiveRecord::Snapshot
  class ListTest < ActiveSupport::TestCase
    extend MiniTest::Spec::DSL

    describe "::add" do
      let(:file) { Tempfile.new }
      before do
        List.stubs(path: file.path)
      end
      after do
        file.unlink
      end

      it "prepends the new content" do
        List.add(version: 1, file: "/path/to/foo")
        List.add(version: 2, file: "/path/to/bar")

        assert_equal <<~CONTENTS, File.read(file)
          2 bar
          1 foo
        CONTENTS
      end
    end

    describe "when the file has content" do
      let(:file) { Tempfile.new }
      before do
        List.stubs(path: file.path)
        List.add(version: 1, file: "/path/to/foo")
        List.add(version: 2, file: "/path/to/bar")
        List.add(version: 3, file: "/path/to/baz")
      end

      after do
        file.unlink
      end

      describe "::get" do
        it "gets the filename for that version" do
          assert_equal [2, "bar"], List.get(version: 2)
        end
      end

      describe "::last" do
        it "gets the last version & filename" do
          assert_equal([3, "baz"], List.last)
        end
      end
    end

    describe "::download" do
      it "downloads to the path" do
        S3.any_instance.expects(:download_to).with(List.path)
        List.download
      end
    end

    describe "::upload" do
      it "uploads to the path" do
        S3.any_instance.expects(:upload).with(List.path)
        List.upload
      end
    end
  end
end
