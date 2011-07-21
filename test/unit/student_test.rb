require 'test_helper'

class StudentTest < ActiveSupport::TestCase
  def test_should_be_valid
    assert Student.new.valid?
  end
end
