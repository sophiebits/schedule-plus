class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    can :read, User, :uid => user.uid
  end
end
