require 'simplecov'
SimpleCov.start do
  add_filter "/test/"
end
GEM_LIB_PATH = Pathname.new(File.expand_path("../../lib", __FILE__))
DUMMY_APP_PATH = Pathname.new(File.expand_path("../../test/dummy", __FILE__))
require File.expand_path("../../test/dummy/config/environment.rb", __FILE__)
require "rails/test_help"
require 'mocha/mini_test'

Mocha::Configuration.prevent(:stubbing_non_existent_method)

# Filter out Minitest backtrace while allowing backtrace from other libraries
# to be shown.
Minitest.backtrace_filter = Minitest::BacktraceFilter.new

Rails::TestUnitReporter.executable = 'bin/test'

# Load fixtures from the engine
ActiveSupport::TestCase.file_fixture_path = File.expand_path("../../test/fixtures/files", __FILE__)
