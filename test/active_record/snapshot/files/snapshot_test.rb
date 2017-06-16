require "test_helper"
require "minitest/spec"

module ActiveRecord::Snapshot
  class SnapshotTest < ActiveSupport::TestCase
    extend MiniTest::Spec::DSL

    subject { Snapshot.new(filename) }
    let(:filename) { "foo.sql" }

    describe "#dump" do
      describe "given a filename" do
        it "uses that filename" do
          assert_equal filename, subject.dump
        end

        describe "when the filename has extensions" do
          let(:filename) { "foo.sql.bz2.enc" }

          it "strips extensions that are not sql" do
            assert_equal "foo.sql", subject.dump
          end
        end
      end

      describe "given no filename" do
        let(:filename) { nil }
        let(:sometime) { Time.zone.parse("2012-01-01") }

        it "defaults to a timestamped snapshot" do
          travel_to(sometime) do
            assert_equal(
              "snapshot_2012-01-01_00-00-00.sql",
              File.basename(subject.dump)
            )
          end
        end
      end
    end

    describe "#compressed" do
      it "adds the .bz2 extension" do
        assert_equal filename + ".bz2", subject.compressed
      end
    end

    describe "#encrypted" do
      it "adds the .bz2.enc extension" do
        assert_equal filename + ".bz2.enc", subject.encrypted
      end
    end

    describe "#download" do
      it "downloads to the path" do
        S3.any_instance.expects(:download_to).with(subject.encrypted)
        subject.download
      end
    end

    describe "#upload" do
      it "uploads to the path" do
        S3.any_instance.expects(:upload).with(subject.encrypted)
        subject.upload
      end
    end
  end
end
