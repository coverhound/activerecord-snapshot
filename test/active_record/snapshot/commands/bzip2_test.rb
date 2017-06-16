require "test_helper"
require "minitest/spec"

module ActiveRecord::Snapshot
  class Bzip2Test < ActiveSupport::TestCase
    extend MiniTest::Spec::DSL

    describe "::compress" do
      it "returns false if it's not a file" do
        assert_equal false, Bzip2.compress("foo")
      end

      it "shells out when it's a file" do
        Object.any_instance.expects(:system)
        Bzip2.compress(__FILE__)
      end
    end

    describe "::decompress" do
      it "returns false if it's not a file" do
        assert_equal false, Bzip2.decompress("foo")
      end

      it "shells out when it's a file" do
        Object.any_instance.expects(:system)
        Bzip2.decompress(__FILE__)
      end
    end
  end
end
