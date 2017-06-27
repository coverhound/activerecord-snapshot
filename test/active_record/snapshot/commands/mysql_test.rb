require "test_helper"
require "minitest/spec"

module ActiveRecord::Snapshot
  class MySQLTest < ActiveSupport::TestCase
    extend MiniTest::Spec::DSL

    let(:tables) { %w[foo bar] }
    let(:file) { "baz" }

    describe "::dump" do
      it "dumps the schema and the data" do
        Object.any_instance.expects(:system).with(<<~SH).once.returns(true)
          nice mysqldump \\
            --user=bearnardo \\
            --password=secret \\
            --host=Jon\\ Stewart \\
            --no-data mainframe > baz
        SH
        Object.any_instance.expects(:system).with(<<~SH).once
          nice mysqldump \\
            --user=bearnardo \\
            --password=secret \\
            --host=Jon\\ Stewart \\
            --quick mainframe foo bar >> baz
        SH

        MySQL.dump(tables: tables, output: file)
      end

      describe "when the password is empty" do
        before do
          ActiveRecord::Snapshot.config.db.class.any_instance.stubs(:password)
        end

        it "handles it" do
          Object.any_instance.expects(:system).with(<<~SH).once.returns(true)
            nice mysqldump \\
              --user=bearnardo \\
               \\
              --host=Jon\\ Stewart \\
              --no-data mainframe > baz
          SH
          Object.any_instance.expects(:system).with(<<~SH).once
            nice mysqldump \\
              --user=bearnardo \\
               \\
              --host=Jon\\ Stewart \\
              --quick mainframe foo bar >> baz
          SH

          MySQL.dump(tables: tables, output: file)
        end
      end
    end

    describe "::import" do
      it "imports the data" do
        Object.any_instance.expects(:system).with(<<~SH).once
          nice mysql \\
            --user=bearnardo \\
            --password=secret \\
            --host=Jon\\ Stewart \\
            mainframe < baz
        SH

        MySQL.import(input: file)
      end

      describe "when the password is empty" do
        before do
          ActiveRecord::Snapshot.config.db.class.any_instance.stubs(:password)
        end

        it "handles it" do
          Object.any_instance.expects(:system).with(<<~SH).once
            nice mysql \\
              --user=bearnardo \\
               \\
              --host=Jon\\ Stewart \\
              mainframe < baz
          SH

          MySQL.import(input: file)
        end
      end
    end
  end
end
