require 'test_helper'

class ActiveRecord::Snapshot::Test < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Module, ActiveRecord::Snapshot
  end
end
