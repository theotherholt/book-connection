class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.references :user
      t.references :buyer
      t.references :book
      t.integer    :edition
      t.integer    :condition_id
      t.string     :state, :null => :no, :default => 'passive'
      t.decimal    :price, :precision => 5, :scale => 2
      t.datetime   :sold_at
      t.timestamps
    end
  end

  def self.down
    drop_table :posts
  end
end
