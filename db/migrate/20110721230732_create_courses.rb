class CreateCourses < ActiveRecord::Migration
  def self.up
    create_table :courses do |t|
      t.string :course_number
      t.string :section
      t.string :name
      t.text :description
      t.integer :units
      t.time :lecture_time
      t.integer :lecture_duration
      t.string :lecture_days
      t.string :lecture_room
      t.time :recitation_time
      t.integer :recitation_duration
      t.string :recitation_room
      t.string :recitation_days
      t.timestamps
    end
  end

  def self.down
    drop_table :courses
  end
end
