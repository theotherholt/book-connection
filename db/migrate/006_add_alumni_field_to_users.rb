class AddAlumniFieldToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :alumni, :boolean, :default => false
  end

  def self.down
    remove_column :users, :alumni
  end
end
