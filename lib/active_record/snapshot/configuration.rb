require "yaml"
require "hashie"

# NOTE: Default lambdas below all have because of a bug with defaults + coercion
#       Defaults aren't executed on class instantiation unless the lambda
#       takes an argument. This is a problem, since the execution in #[]=
#       happens AFTER the value is assigned - therefore AFTER the
#       coercion happens

module ActiveRecord
  module Snapshot
    class ConfigClass < Hashie::Dash
      include Hashie::Extensions::Dash::Coercion
      include Hashie::Extensions::Dash::IndifferentAccess
    end

    class Configuration < ConfigClass
      class S3Paths < ConfigClass
        property :snapshots, required: true
        property :named_snapshots, required: true
      end

      class S3Config < ConfigClass
        property :access_key_id, required: true
        property :secret_access_key, required: true
        property :bucket, required: true
        property :region, default: "us-west-1"
        property :paths, required: true, coerce: S3Paths
      end

      class DBConfig < ConfigClass
        def initialize(env)
          database_hash = ::Rails.application.config.database_configuration[env]
          super(database_hash.slice("database", "username", "password", "host"))
        end

        property :database, required: true
        property :username, required: true
        property :host, required: true
        property :password
      end

      class StoreConfig < ConfigClass
        property :tmp, default: ->(_) { ::Rails.root.join("tmp/snapshots") }, coerce: Pathname
        property :local, default: ->(_) { ::Rails.root.join("db/snapshots") }, coerce: Pathname
      end

      include Singleton

      def initialize
        super(read_config_file)
        @env = ENV.fetch("SNAPSHOT_ENV", Rails.env)
      end

      attr_accessor :env

      property :s3, required: true, coerce: S3Config
      property :ssl_key, required: true
      property :tables, required: true
      property :store, coerce: StoreConfig

      def db
        DBConfig.new(env)
      end

      def adapter
        ActiveRecord::Snapshot::MySQL
      end

      private

      def config_file
        ::Rails.root.join("config", "snapshot.yml")
      end

      def read_config_file
        contents = File.read(config_file)
        interpolated = ERB.new(contents).result
        YAML.safe_load(interpolated)
      end
    end

    def self.config
      Configuration.instance
    end
  end
end
