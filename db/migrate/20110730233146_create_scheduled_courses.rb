class CreateScheduledCourses < ActiveRecord::Migration
  def self.up
    create_table :scheduled_courses do |t|
      t.integer :course_id
      t.string :lecture_section
      t.string :recitation_section

      t.timestamps
    end
  end

  def self.down
    drop_table :scheduled_courses
  end
end
