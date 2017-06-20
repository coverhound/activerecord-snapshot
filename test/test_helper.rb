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

if Rails.const_defined?("TestUnitReporter")
  Rails::TestUnitReporter.executable = 'bin/test'
end

# Load fixtures from the engine
unless ActiveSupport::TestCase.respond_to?(:file_fixture_path)
  class ActiveSupport::TestCase
    cattr_accessor :file_fixture_path

    def file_fixture(file_path)
      File.new(File.join(self.class.file_fixture_path, file_path))
    end
  end
end
ActiveSupport::TestCase.file_fixture_path = File.expand_path("../../test/fixtures/files", __FILE__)
