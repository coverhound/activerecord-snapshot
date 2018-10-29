module ActiveRecord
  module Snapshot
    class OpenSSL
      def self.encrypt(input:, output:)
        system(<<-SH)
        nice openssl aes-256-cbc -md sha256 \\
          -in #{input} \\
          -out #{output} \\
          -kfile #{ActiveRecord::Snapshot.config.ssl_key}
        SH
      end

      def self.decrypt(input:, output:)
        system(<<-SH)
        nice openssl enc -d -aes-256-cbc -md sha256 \\
          -in #{input} \\
          -out #{output} \\
          -kfile #{ActiveRecord::Snapshot.config.ssl_key}
        SH
      end
    end
  end
end
