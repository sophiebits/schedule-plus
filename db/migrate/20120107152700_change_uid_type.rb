class ChangeUidType < ActiveRecord::Migration
  def self.up
    change_column :users, :uid, :bigint
    change_column :authentications, :uid, :bigint
  end

  def self.down
    change_column :users, :uid, :integer
    change_column :authentications, :uid, :integer
  end
end
