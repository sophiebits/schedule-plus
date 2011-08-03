class CreateRecitationSectionTimes < ActiveRecord::Migration
  def self.up
    create_table :recitation_section_times do |t|
      t.integer :recitation_id
      t.string :day
      t.string :begin
      t.string :end
      t.string :location

#      t.timestamps
    end
  end

  def self.down
    drop_table :recitation_section_times
  end
end
