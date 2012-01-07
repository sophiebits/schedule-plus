class RenameActiveToPrimary < ActiveRecord::Migration
  def self.up
    rename_column(:schedules, 'active', 'primary')
  end

  def self.down
    rename_column(:schedules, 'primary', 'active')
  end
end
