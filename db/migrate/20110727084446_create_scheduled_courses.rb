class CreateScheduledCourses < ActiveRecord::Migration
  def self.up
    create_table :scheduled_courses do |t|
      t.string :course_number
      t.string :section

      t.timestamps
    end
  end

  def self.down
    drop_table :scheduled_courses
  end
end
