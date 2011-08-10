class CreateRecitations < ActiveRecord::Migration
  def self.up
    create_table :recitations do |t|
      t.integer :lecture_id
      t.string :section
      t.string :instructor

#      t.timestamps
    end
  end

  def self.down
    drop_table :recitations
  end
end
