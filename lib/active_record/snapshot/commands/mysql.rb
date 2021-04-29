require 'shellwords'

module ActiveRecord
  module Snapshot
    class MySQL
      def self.dump(*args)
        new.dump(*args)
      end

      def dump(tables:, output:)
        dump_command("--no-data --set-gtid-purged=OFF #{database} > #{output}") &&
          dump_command("--quick --set-gtid-purged=OFF #{database} #{tables.join(" ")} >> #{output}")
      end

      def self.import(*args)
        new.import(*args)
      end

      def import(input:)
        system(<<~SH)
          nice mysql \\
            --user=#{username} \\
            #{password_string} \\
            --host=#{host} \\
            #{database} < #{input}
        SH
      end

      private

      def db_config
        ActiveRecord::Snapshot.config.db
      end

      def escape(value)
        Shellwords.escape(value)
      end

      def username
        escape(db_config.username)
      end

      def password_string
        return if db_config.password.blank?
        "--password=#{escape(db_config.password)}"
      end

      def host
        escape(db_config.host)
      end

      def database
        escape(db_config.database)
      end

      def dump_command(args = "")
        system(<<~SH)
          nice mysqldump \\
            --user=#{username} \\
            #{password_string} \\
            --host=#{host} \\
            #{args}
        SH
      end
    end
  end
end
