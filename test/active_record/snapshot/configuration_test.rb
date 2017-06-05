require "test_helper"
require "minitest/spec"

module ActiveRecord::Snapshot
  class ConfigurationTest < ActiveSupport::TestCase
    extend MiniTest::Spec::DSL

    config = Rails.application.config
    def config.database
      {}
    end

    subject { ActiveRecord::Snapshot.config }

    describe "#s3" do
      it "responds to the appropriate methods" do
        {
          access_key_id: "foo",
          secret_access_key: "bar",
          bucket: "metal-bucket",
          region: "us-west-1"
        }.each do |name, value|
          assert_equal value, subject.s3.public_send(name)
        end

        {
          named_snapshots: "named_snapshots",
          snapshots: "snapshots"
        }.each do |name, value|
          assert_equal value, subject.s3.paths.public_send(name)
        end
      end
    end

    describe "#store" do
      it "responds to the appropriate methods" do
        {
          tmp: Pathname.new("/mnt/tmp"),
          local: Rails.root.join("db/snapshots")
        }.each do |name, value|
          assert_equal value, subject.store.public_send(name)
        end
      end
    end

    describe "#tables" do
      it "returns the tables" do
        assert_equal %w[example_table], subject.tables
      end
    end

    describe "#ssl_key" do
      it "returns the ssl key" do
        assert_equal "/dir/to/snapshots-secret.key", subject.ssl_key
      end
    end

    describe "#adapter" do
      it "returns our MySQL adapter" do
        assert_equal ActiveRecord::Snapshot::MySQL, subject.adapter
      end
    end
  end
end
