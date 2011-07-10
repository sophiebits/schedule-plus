require 'test_helper'

class SchedulesControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end

  def test_show
    get :show, :id => Schedule.first
    assert_template 'show'
  end

  def test_new
    get :new
    assert_template 'new'
  end

  def test_create_invalid
    Schedule.any_instance.stubs(:valid?).returns(false)
    post :create
    assert_template 'new'
  end

  def test_create_valid
    Schedule.any_instance.stubs(:valid?).returns(true)
    post :create
    assert_redirected_to schedule_url(assigns(:schedule))
  end

  def test_edit
    get :edit, :id => Schedule.first
    assert_template 'edit'
  end

  def test_update_invalid
    Schedule.any_instance.stubs(:valid?).returns(false)
    put :update, :id => Schedule.first
    assert_template 'edit'
  end

  def test_update_valid
    Schedule.any_instance.stubs(:valid?).returns(true)
    put :update, :id => Schedule.first
    assert_redirected_to schedule_url(assigns(:schedule))
  end

  def test_destroy
    schedule = Schedule.first
    delete :destroy, :id => schedule
    assert_redirected_to schedules_url
    assert !Schedule.exists?(schedule.id)
  end
end
