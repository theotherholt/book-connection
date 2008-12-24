class AddPostsForSaleCounterCacheToBooks < ActiveRecord::Migration
  def self.up
    add_column :books, :posts_for_sale_count, :integer, :default => 0
    
    Book.suspended_delta do
      Book.find(:all, :include => :posts).each do |book|
        book.update_attribute(:posts_for_sale_count, book.posts.for_sale.size)
      end
    end
  end

  def self.down
    remove_column :books, :posts_for_sale_count
  end
end
