# ActiveRecord::Snapshot

This gem provides rake tasks to create and import MySQL snapshots using S3. This
is pretty specialized for how CoverHound uses snapshots.

## Dependencies

- S3
- MySQL
- bzip2
- openssl

## Usage

### Configuration

This file, looked for at `config/snapshot.yml`, allows for the following
configuration:

- `store.tmp` Working directory for snapshots
- `store.local` Local storage of snapshots
- `s3.*` S3 access keys, bucket, region and paths for storing regular and named
  snapshots
- `ssl_key` Path to the key that will be used to encrypt the snapshot
- `tables` The tables that should be exported as part of the snapshot

##### Sample

```yml
# config/snapshot.yml
store:
  tmp: <%= Rails.root.join("tmp/snapshots").to_s %>
  local: <%= Rails.root.join("db/snapshots").to_s %>

s3:
  access_key_id: 'foo'
  secret_access_key: 'bar'
  bucket: 'metal-bucket'
  region: 'us-west-1'
  paths:
    snapshots: 'snapshots'
    named_snapshots: 'named_snapshots'

ssl_key: "/dir/to/snapshots-secret.key"

tables:
- "example_table"
```

### Tasks

##### `db:snapshot:create`

Creates a snapshot with the following naming convention:
`snapshot_YY-MM-DD_HH-MM.sql.bz2.enc`

This snapshot is then stored at `s3.paths.snapshots`. It is assigned a version
(incrementing off of a `snapshot_version` file, which is saved locally and on
S3) which is stored alongside its filename in the file `snapshot_list`.

This task only runs in production.

##### `db:snapshot:create_named`

Creates a named snapshot: `[name].sql.bz2.enc` which is stored at
`s3.paths.named_snapshots`. These are not stored in `snapshot_list` or
`snapshot_version`.

##### `db:snapshot:import`

When used without arguments, it imports the latest regular snapshot from S3,
then drops and replaces the local database.

Can be given arguments for the version:

`db:snapshot:import[12]` gets you the 12th regular snapshot
`db:snapshot:import['foo']` gets you your snapshot named `foo`

##### `db:snapshot:import:only['foo bar']`

Imports _only_ the tables given as arguments (`foo` and `bar` in this example)
from the latest regular snapshot

##### `db:snapshot:reload`

Reloads the current snapshot

##### `db:snapshot:list`

Shows a list of snapshots

##### `db:snapshot:list:load[n]`

Shows a list of the last `n` snapshots

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'activerecord-snapshot'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install activerecord-snapshot
```

## Contributing

Be nice!

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
