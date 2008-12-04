class AddCounterCacheToPosts < ActiveRecord::Migration
  def self.up
    add_column :books, :posts_count, :integer, :default => 0
    
    Book.reset_column_information
    Book.find(:all).each do |book|
      Book.update_counters(book.id, :posts_count => book.posts.size)
    end
  end

  def self.down
    remove_column :books, :posts_count
  end
end
