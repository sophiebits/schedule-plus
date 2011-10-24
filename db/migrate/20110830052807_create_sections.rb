class CreateSections < ActiveRecord::Migration
  def self.up
    create_table :sections do |t|
      t.integer :course_id
      t.integer :lecture_id
      t.string :letter
      t.string :instructor
      t.boolean :offered

      t.timestamps
    end
  end

  def self.down
    drop_table :sections
  end
end
