class CreateScheduledTimes < ActiveRecord::Migration
  def self.up
    create_table :scheduled_times do |t|
      t.integer :schedulable_id
      t.string :schedulable_type
      t.string :days
      t.integer :begin
      t.integer :end
      t.string :location

      t.timestamps
    end
  end

  def self.down
    drop_table :scheduled_times
  end
end
