class SchedulesController < ApplicationController
  respond_to :html, :js
  def import
    # parse params[:url]
    @schedule = User.find(3)
  end
  
  def new
    # release 2
  end

  def show
    # @schedule = Schedule.find(params[:id])
  end
end
