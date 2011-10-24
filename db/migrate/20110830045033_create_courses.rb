class CreateCourses < ActiveRecord::Migration
  def self.up
    create_table :courses do |t|
      t.string :number
      t.string :name
      t.string :units
      t.string :instructor
      t.string :semester

      t.timestamps
    end
  end

  def self.down
    drop_table :courses
  end
end