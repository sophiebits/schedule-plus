class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string  :name
      t.integer :uid
      t.string  :andrew
      t.boolean :private

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
