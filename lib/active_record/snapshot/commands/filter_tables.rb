module ActiveRecord
  module Snapshot
    class FilterTables
      def self.call(*args)
        new(*args).call
      end

      def initialize(tables:, sql_dump:)
        @tables = tables
        @sql_dump = sql_dump
      end

      def call
        tables.each(&method(:extract_table))
        unify_tables
      end

      private

      attr_reader :tables, :sql_dump

      def table_file(table)
        ActiveRecord::Snapshot.config.store.tmp.join("#{table}.sql").to_s
      end

      def extract_table(table)
        system(<<~SH)
          sed -ne \\
            '/Table structure for table `#{table}`/,/Table structure for table/p' \\
            #{sql_dump} \\
            > #{table_file(table)}
        SH
      end

      def unify_tables
        all = tables.map(&method(:table_file)).join(" ")
        system("cat #{all} > #{sql_dump}")
      end
    end
  end
end
