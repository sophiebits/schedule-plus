class CreateActiveSchedules < ActiveRecord::Migration
  def self.up
    create_table :active_schedules do |t|
      t.integer :user_id
      t.integer :schedule_id

      t.timestamps
    end
  end

  def self.down
    drop_table :active_schedules
  end
end
