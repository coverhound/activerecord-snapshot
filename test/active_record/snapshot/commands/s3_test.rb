require "test_helper"
require "minitest/spec"

module ActiveRecord::Snapshot
  class S3Test < ActiveSupport::TestCase
    extend MiniTest::Spec::DSL

    let(:fog_connection) { mock("Fog Connection") }

    describe "::new" do
      it "creates a fog connection" do
        ::Fog::Storage.expects(:new)
        S3.new(directory: "foo")
      end
    end

    describe "S3" do
      subject { S3.new(directory: directory) }
      let(:directory) { "bar" }
      let(:file) { Tempfile.new }

      before do
        ::Fog::Storage.expects(:new).returns(fog_connection)
      end
      after do
        file.unlink
      end

      describe "#upload" do
        it "calls #put_object on the connection" do
          fog_connection.expects(:put_object)
          subject.upload(file.path)
        end
      end

      describe "#read" do
        let(:body) { "foo" }
        it "calls #put_object on the connection" do
          fog_connection.expects(:get_object).returns(stub(body: body))
          assert_equal body, subject.read(file.path)
        end
      end

      describe "#download_to" do
        let(:contents) { "foo" }

        it "calls #put_object on the connection" do
          subject.expects(:read).returns(contents)
          subject.download_to(file.path)
          assert_equal contents, file.read
        end
      end
    end
  end
end
