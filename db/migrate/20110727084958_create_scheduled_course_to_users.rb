class CreateScheduledCourseToUsers < ActiveRecord::Migration
  def self.up
    create_table :scheduled_course_to_users do |t|
      t.integer :scheduled_course_id
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :scheduled_course_to_users
  end
end
