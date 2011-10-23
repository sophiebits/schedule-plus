class CreateLectureSectionTimes < ActiveRecord::Migration
  def self.up
    create_table :lecture_section_times do |t|
      t.integer :lecture_id
      t.string :day
      t.integer :begin
      t.integer :end
      t.string :location

#      t.timestamps
    end
  end

  def self.down
    drop_table :lecture_section_times
  end
end
