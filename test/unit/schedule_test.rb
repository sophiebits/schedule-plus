require 'test_helper'

class ScheduleTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert Schedule.new.valid?
  end
end
