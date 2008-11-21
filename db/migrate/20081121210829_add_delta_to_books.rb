class AddDeltaToBooks < ActiveRecord::Migration
  def self.up
    add_column :books, :delta, :boolean
  end

  def self.down
    ActiveRecord::IrreversibleMigration
  end
end
