class CreateCourseSelections < ActiveRecord::Migration
  def self.up
    create_table :course_selections do |t|
      t.integer :schedule_id
      t.integer :section_id

      t.timestamps
    end
  end

  def self.down
    drop_table :course_selections
  end
end
