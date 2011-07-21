require 'test_helper'

class SchedulesTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert Schedules.new.valid?
  end
end
