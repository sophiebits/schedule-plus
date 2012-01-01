class CreateSemesters < ActiveRecord::Migration
  def self.up
    create_table :semesters do |t|
      t.string :name
      t.string :short_name
      t.boolean :current
      
      t.timestamps
    end
  end

  def self.down
    drop_table :semesters
  end
end
