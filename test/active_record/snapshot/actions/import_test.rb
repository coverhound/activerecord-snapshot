require "test_helper"
require "minitest/spec"

module ActiveRecord::Snapshot
  class ImportTest < ActiveSupport::TestCase
    extend MiniTest::Spec::DSL

    let(:rake_task) { stub("Rake Task", invoke: true) }
    before do
      Object.any_instance.stubs(:puts)
    end

    describe "::call" do
      describe "given no version" do
        let(:version) { nil }
        before do
          Stepper.stubs(:call)
        end

        it "selects a snapshot" do
          SelectSnapshot.expects(:call).with(version)
          Import.call(version: version)
        end
      end

      describe "given a numbered version" do
        let(:version) { "5" }
        before do
          Stepper.stubs(:call)
        end

        it "selects a snapshot" do
          SelectSnapshot.expects(:call).with(version)
          Import.call(version: version)
        end
      end

      describe "given a string version" do
        let(:version) { "foo" }
        before do
          Stepper.stubs(:call)
        end

        it "takes the version verbatim" do
          SelectSnapshot.expects(:call).never
          Import.call(version: version)
        end
      end

      describe "when the version has been downloaded" do
        let(:version) { 15 }
        before do
          Version.expects(current: version, write: true).once
          SelectSnapshot.stubs(:call)
          Rake::Task.stubs(:[]).returns(rake_task)
          run_steps
        end

        it "skips the download and extraction" do
          Snapshot.any_instance.expects(:download).never
          OpenSSL.expects(:decrypt).never
          Bzip2.expects(:decompress).never

          Import.call(version: version)
        end
      end

      describe "given no tables" do
        it "resets the database" do
          run_steps
          Rake::Task.expects(:[]).with("db:drop").returns(rake_task).once
          Rake::Task.expects(:[]).with("db:create").returns(rake_task).once

          Import.call(version: "foo")
        end
      end

      describe "given tables" do
        it "filters the database" do
          run_steps
          FilterTables.expects(call: true).once

          Import.call(version: "foo", tables: %w[foo bar])
        end
      end

      def run_steps
        Snapshot.any_instance.expects(download: true).once
        OpenSSL.expects(decrypt: true).once
        FileUtils.expects(rm: true).once
        Bzip2.expects(decompress: true).once
        MySQL.expects(import: true).once
        Rake::Task.expects(:[]).with("db:schema:dump").returns(rake_task).once
      end
    end
  end
end
