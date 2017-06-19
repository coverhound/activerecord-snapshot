require "yaml"
require "hashie"

# NOTE: Default lambdas below all have because of a bug with defaults + coercion
#       Defaults aren't executed on class instantiation unless the lambda
#       takes an argument. This is a problem, since the execution in #[]=
#       happens AFTER the value is assigned - therefore AFTER the
#       coercion happens

module ActiveRecord
  module Snapshot
    class Configuration < Hashie::Dash
      class S3Paths < Hashie::Dash
        include Hashie::Extensions::Dash::IndifferentAccess

        property :snapshots, required: true
        property :named_snapshots, required: true
      end

      class S3Config < Hashie::Dash
        include Hashie::Extensions::Dash::Coercion
        include Hashie::Extensions::Dash::IndifferentAccess

        property :access_key_id, required: true
        property :secret_access_key, required: true
        property :bucket, required: true
        property :region, default: "us-west-1"
        property :paths, required: true, coerce: S3Paths
      end

      class DBConfig < Hashie::Dash
        include Hashie::Extensions::Dash::IndifferentAccess

        def initialize(database_hash)
          super database_hash.slice("database", "username", "password", "host")
        end

        property :database, required: true
        property :username, required: true
        property :password, required: true
        property :host, required: true
      end

      class StoreConfig < Hashie::Dash
        include Hashie::Extensions::Dash::Coercion
        include Hashie::Extensions::Dash::IndifferentAccess

        property :tmp, default: ->(_) { ::Rails.root.join("tmp/snapshots") }, coerce: Pathname
        property :local, default: ->(_) { ::Rails.root.join("db/snapshots") }, coerce: Pathname
      end

      include Hashie::Extensions::Dash::Coercion
      include Hashie::Extensions::Dash::IndifferentAccess

      property :db, default: ->(_) { ::Rails.application.config.database_configuration[Rails.env] }, coerce: DBConfig
      property :s3, required: true, coerce: S3Config
      property :ssl_key, required: true
      property :tables, required: true
      property :store, coerce: StoreConfig

      def adapter
        ActiveRecord::Snapshot::MySQL
      end
    end

    def self.config_file
      ::Rails.root.join("config", "snapshot.yml")
    end

    def self.config
      @config ||= Configuration.new(YAML.safe_load(ERB.new(::File.read(config_file)).result))
    end
  end
end
