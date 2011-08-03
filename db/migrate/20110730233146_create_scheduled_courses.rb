class CreateScheduledCourses < ActiveRecord::Migration
  def self.up
    create_table :scheduled_courses do |t|
      t.integer :course_id
      t.integer :lecture_id
      t.integer :recitation_id

      t.timestamps
    end
  end

  def self.down
    drop_table :scheduled_courses
  end
end
