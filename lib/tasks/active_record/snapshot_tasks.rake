namespace :db do
  namespace :snapshot do
    desc "Create a snapshot of the current database and store it in S3"
    task create: :load do
      abort "Meant for production only!" unless Rails.env.production?
      ActiveRecord::Snapshot::Create.call
    end

    desc "Take a snapshot of the current database and store it in S3"
    task create_named: :load do
      abort "Do not run in production!" if Rails.env.production?
      puts <<~TEXT
        Please enter a unique name for this snapshot. You will need to remember this to access it later:
      TEXT

      snapshot_name = gets.strip

      abort "Please don't use spaces in your snapshot name." if snapshot_name =~ /\s/
      abort "Please ensure your name is a string, integers are used for daily snapshots" if snapshot_name.to_i.to_s == snapshot_name

      ActiveRecord::Snapshot::Create.call(name: snapshot_name)
    end

    desc "Import production database snapshot."
    task :import, [:version] => [:load] do |_t, args|
      abort "Do not run in prodution mode!" if Rails.env.production?
      version = args.fetch(:version, "").strip
      ActiveRecord::Snapshot::Import.call(version: version)
    end

    namespace :import do
      desc "Import only specific tables from the most recent snapshot"
      task :only, [:tables] => :load do |_t, args|
        abort "Do not run in production mode!" if Rails.env.production?

        if args[:tables].blank?
          abort "Usage: bundle exec rake db:snapshot:import:only['table1 table2']"
        end

        tables = args[:tables].split(/[, ;]+/)
        ActiveRecord::Snapshot::Import.call(tables: tables)
      end
    end

    desc "Reload current snapshot version"
    task reload: :load do
      version = ActiveRecord::Snapshot::Version.current
      abort "No current version found" unless version
      Rake::Task["db:snapshot:import"].invoke(version)
    end

    desc "Show available snapshot versions"
    task list: :load do
      version = ActiveRecord::Snapshot::Version.current
      puts "Current snapshot version is #{version}" if version
      puts File.read(ActiveRecord::Snapshot::List.path)
    end

    namespace :list do
      desc "Show last n available snapshot versions"
      task :last, [:count] => [:load] do |_t, args|
        version = ActiveRecord::Snapshot::Version.current
        puts "Current snapshot version is #{version}" if version

        lines = File.readlines(ActiveRecord::Snapshot::List.path)
        count = [1, args[:count].to_i].max

        puts lines[0..count]
      end
    end

    task load: :environment do
      FileUtils.mkdir_p(ActiveRecord::Snapshot.config.store.values)
    end
  end
end
