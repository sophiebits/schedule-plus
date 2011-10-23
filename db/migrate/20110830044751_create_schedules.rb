class CreateSchedules < ActiveRecord::Migration
  def self.up
    create_table :schedules do |t|
      t.integer :user_id
      t.string :name
      t.string :semester
      t.boolean :active

      t.timestamps
    end
  end

  def self.down
    drop_table :schedules
  end
end
