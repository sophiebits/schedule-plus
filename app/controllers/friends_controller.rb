class FriendsController < ApplicationController
  def show
    @friends = friends
  end
end
