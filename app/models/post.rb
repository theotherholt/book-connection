class Post < ActiveRecord::Base
  ##
  # Thrown when a user attempts to purchase a book that has already been
  # purchased.
  class PostNotAvailable < StandardError; end
  
  #--
  # Validations
  #++
  validates_presence_of     :user_id, :message => 'must belong to a user'
  validates_presence_of     :book_id, :message => 'must have an associated book'
  validates_presence_of     :condition_id, :price
  validates_numericality_of :price
  validates_numericality_of :edition, :allow_blank => true
  
  #--
  # Relations
  #++
  belongs_to :user
  belongs_to :book,
             :counter_cache => true
  belongs_to :buyer,
             :class_name  => 'User',
             :foreign_key => 'buyer_id'
  
  ##
  # Returns the set of posts ordered by their book's title.
  named_scope :ordered_by_title,
              :include => :book,
              :order   => 'books.title ASC'
  
  ##
  # Returns the set of posts ordered by their price.
  named_scope :ordered_by_price, :order => 'posts.price ASC'
  
  ##
  # Returns the set of posts that are currently for sale.
  named_scope :for_sale, :conditions => 'posts.sold_at IS NULL'
  
  ##
  # ==== Returns
  # String::
  #   The condition associated with the condition_id attribute.
  #
  # ==== Notes
  # Rather than store this information in the database, the condition strings
  # associated with the various condition_ids are stored in the CONDITION
  # array here in the Post model.
  def condition_with_formatting
    Constants::CONDITION[self.condition_id - 1][0]
  end
  
  ##
  # ==== Returns
  # String::
  #   The ordinalized edition of the post if one is set, otherwise N/A.
  def edition_with_formatting
    (attribute_present?('edition')) ? self.edition.ordinalize : 'N/A'
  end
  
  ##
  # Set's the post's edition attribute, attempting to do some data cleaning in
  # the process.
  #
  # ==== Parameters
  # edition<~to_s>::
  #   The post's edition.
  #
  # ==== Notes
  # This method plays the delicate game of attempting to sanitize user data. It
  # strips all formatting out of any edition it's given. So if the user input
  # '4th' for the edition, this method would attempt to extract '4' from that.
  #
  # However, if it can't extract any valid numbers, then it simply sets whatever
  # the user input, allowing Rails to do the appropirate error handling.
  def edition=(edition)
    clean_edition = edition.to_s.gsub(/[^0-9]/, '').to_i
    
    if clean_edition.zero?
      self[:edition] = edition
    else
      self[:edition] = clean_edition
    end
  end
  
  ##
  # Marks a post as 'for sale', allowing it to be listed in searches.
  def list!
    self.sold_at = nil
    self.buyer   = nil
    self.book.posts_for_sale_count += 1
    self.save
  end
  
  ##
  # ==== Returns
  # String::
  #   The post's price, formatted as currency.
  def price_with_formatting
    ActionController::Base.helpers.number_to_currency(self.price)
  end
  
  ##
  # Set's the post's price attribute, attempting to do some data cleaning in
  # the process.
  #
  # ==== Parameters
  # price<~to_s>::
  #   The post's price.
  #
  # ==== Notes
  # This method plays the delicate game of attempting to sanitize user data. It
  # strips all formatting out of any price it's given. So if the user input
  # '$9.00' for the price, this method would attempt to extract '9.00' from that.
  #
  # However, if it can't extract any valid numbers, then it simply sets whatever
  # the user input, allowing Rails to do the appropirate error handling.
  def price=(price)
    clean_price = price.to_s.gsub(/\$/, '').to_f
    
    if clean_price.zero?
      self[:price] = price
    else
      self[:price] = clean_price
    end
  end
  
  ##
  # "Sells" a posted book to a buyer, associating that user with the buyer_id
  # of the post.
  #
  # ==== Parameters
  # buyer<User>::
  #   The user who wants to buy this posted book.
  #
  # ==== Raises
  # PostNotAvailable::
  #   If the post isn't for sale.
  def purchase(buyer)
    raise PostNotAvailable unless self.sold_at.nil?
    
    self.buyer   = buyer
    self.sold_at = Time.now
    self.book.posts_for_sale_count -= 1
    self.save
  end
  
  ##
  # ==== Returns
  # Boolean::
  #   True if a book's +sold_at+ field is set and a book is 'for sale'.
  def sold?
    !self.sold_at.nil?
  end
  
  ##
  # ==== Returns
  # String::
  #   A neatly formatted state string.
  def state_with_formatting
    if self.sold?
      'Sold'
    else
      'For sale'
    end
  end
end