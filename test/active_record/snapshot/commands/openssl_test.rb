require "test_helper"
require "minitest/spec"

module ActiveRecord::Snapshot
  class OpenSSLTest < ActiveSupport::TestCase
    extend MiniTest::Spec::DSL

    subject { OpenSSL }

    describe "::encrypt" do
      it "calls out to shell" do
        Object.any_instance.expects(:system)
        subject.encrypt(input: "foo", output: "bar")
      end
    end

    describe "::decrypt" do
      it "calls out to shell" do
        Object.any_instance.expects(:system)
        subject.decrypt(input: "foo", output: "bar")
      end
    end
  end
end
