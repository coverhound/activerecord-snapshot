require_relative 'boot'

# Pick the frameworks you want:
# require "active_record/railtie"
require "action_controller/railtie"
require "action_view/railtie"
# require "action_mailer/railtie"
require "active_job/railtie"
# require "action_cable/engine"
require "rails/test_unit/railtie"
# require "sprockets/railtie"

Bundler.require(*Rails.groups)
require "active_record/snapshot"

module Dummy
  class Application < Rails::Application
    config.eager_load = false
    config.active_support.test_order = :random
  end
end

