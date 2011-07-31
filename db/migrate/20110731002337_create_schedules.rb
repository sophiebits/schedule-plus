class CreateSchedules < ActiveRecord::Migration
  def self.up
    create_table :schedules do |t|
      t.integer :scheduled_course_id
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :schedules
  end
end
