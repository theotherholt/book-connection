class CreateAuthors < ActiveRecord::Migration
  def self.up
    create_table :authors do |t|
      t.string :name
      t.timestamps
    end
    
    create_table :authors_books, :id => false do |t|
      t.references :author
      t.references :book
    end
  end

  def self.down
    drop_table :authors_books
    drop_table :authors
  end
end
