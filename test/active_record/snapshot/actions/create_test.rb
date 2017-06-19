require "test_helper"
require "minitest/spec"

module ActiveRecord::Snapshot
  class CreateTest < ActiveSupport::TestCase
    extend MiniTest::Spec::DSL

    before do
      Object.any_instance.stubs(:puts)
      MySQL.stubs(dump: true)
      Bzip2.stubs(compress: true)
      OpenSSL.stubs(encrypt: true)
      Version.stubs(increment: true, current: 1, next: 2)
      S3.any_instance.stubs(upload: true)
      ActiveRecord::Snapshot.config.stubs(db: stub(database: "bar"))
    end

    describe "::call" do
      describe "given a name" do
        it "runs through" do
          MySQL.expects(dump: true).once
          Bzip2.expects(compress: true).once
          OpenSSL.expects(encrypt: true).once
          Snapshot.any_instance.expects(upload: true).once

          Create.call(name: "foo")
        end
      end

      describe "given no name" do
        it "also uploads version and list" do
          MySQL.expects(dump: true).once
          Bzip2.expects(compress: true).once
          OpenSSL.expects(encrypt: true).once
          Version.expects(increment: true).once
          List.expects(add: true).once
          Snapshot.any_instance.expects(upload: true).once
          Version.expects(upload: true).once
          List.expects(upload: true).once

          Create.call
        end
      end
    end
  end
end
