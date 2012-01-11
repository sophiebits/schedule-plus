class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    can :read, User do |u|
    	(u.id == user.id) or (user.friends.map(&:id).include? u.id) or u.discoverable?
    end
  end
end
