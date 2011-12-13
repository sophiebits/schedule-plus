class CreateCourses < ActiveRecord::Migration
  def self.up
    create_table :courses do |t|
      t.string :number
      t.string :name
      t.string :units
      t.string :instructor
      t.text :description
      t.string :prereqs
      t.string :coreqs
      t.integer :semester_id
      t.integer :department_id
      t.boolean :offered

      t.timestamps
    end
  end

  def self.down
    drop_table :courses
  end
end
