require "test_helper"
require "minitest/spec"

module ActiveRecord::Snapshot
  class ConfigurationTest < ActiveSupport::TestCase
    extend MiniTest::Spec::DSL

    rake = Rake::Application.new
    Rake.application = rake
    Rake.load_rakefile(
      GEM_LIB_PATH.join("tasks/active_record/snapshot_tasks.rake").to_s
    )
    Rake::Task.define_task(:environment)

    before do
      Object.any_instance.stubs(:puts)
      Object.any_instance.stubs(:abort).raises(SystemExit)
    end

    describe "db:snapshot:create" do
      let(:task) { rake["db:snapshot:create"] }
      after { task.reenable }

      it "fails outside of production" do
        assert_raises(SystemExit) { task.invoke }
      end

      it "runs in production" do
        Rails.env.expects(production?: true).once
        ActiveRecord::Snapshot::Create.expects(:call).once
        task.invoke
      end
    end

    describe "db:snapshot:create_named" do
      let(:task) { rake["db:snapshot:create_named"] }
      after { task.reenable }

      it "fails in production" do
        Rails.env.expects(production?: true).once
        assert_raises(SystemExit) { task.invoke }
      end

      it "doesn't accept names with spaces" do
        Object.any_instance.expects(gets: "name with spaces").once
        assert_raises(SystemExit) { task.invoke }
      end

      it "doesn't accept pure numbers" do
        Object.any_instance.expects(gets: "123").once
        assert_raises(SystemExit) { task.invoke }
      end

      it "runs the snapshot" do
        name = "custom"
        Object.any_instance.expects(gets: name).once
        ActiveRecord::Snapshot::Create.expects(:call).with(name: name).once
        task.invoke
      end
    end

    describe "db:snapshot:import" do
      let(:task) { rake["db:snapshot:import"] }
      after { task.reenable }

      it "fails in production" do
        Rails.env.expects(production?: true).once
        assert_raises(SystemExit) { task.invoke }
      end

      it "runs with no arguments" do
        ActiveRecord::Snapshot::Import.expects(:call).with(version: "").once
        task.invoke
      end

      it "runs when given a version" do
        version = "123"
        ActiveRecord::Snapshot::Import.expects(:call).with(version: version).once
        task.invoke(version)
      end
    end

    describe "db:snapshot:import:only" do
      let(:task) { rake["db:snapshot:import:only"] }
      after { task.reenable }

      it "fails in production" do
        Rails.env.stubs(production?: true)
        assert_raises(SystemExit) { task.invoke("foo") }
      end

      it "fails without arguments" do
        assert_raises(SystemExit) { task.invoke }
      end

      it "runs an import with the tables" do
        tables = %w[foo bar]
        ActiveRecord::Snapshot::Import.expects(:call).with(tables: tables)
        task.invoke(tables.join(" "))
      end
    end
  end
end
