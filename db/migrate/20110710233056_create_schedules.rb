class CreateSchedules < ActiveRecord::Migration
  def self.up
    create_table :schedules do |t|
      t.string :semeste
      t.integer :class_id
      t.timestamps
    end
  end

  def self.down
    drop_table :schedules
  end
end
