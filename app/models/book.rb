require 'net/http'
require 'xmlsimple'

class Book < ActiveRecord::Base
  ##
  # Raised when a request to ISBNdb comes back with anything but HTTPOK.
  class LookupFailedError < StandardError; end
  
  #--
  # Validations
  #++
  validates_presence_of   :isbn, :title
  validates_uniqueness_of :isbn
  
  #--
  # Relations
  #++
  has_and_belongs_to_many :authors
  has_many :posts
  
  #--
  # Plugins
  #++
  acts_as_ferret :fields => [ :title ], :remote => true
  
  has_attached_file :photo,
                    :url  => '/images/books/:id/:style/:basename.:extension',
                    :path => ':rails_root/public/images/books/:id/:style/:basename.:extension'
  
  ##
  # Returns the set of books with a given ISBN.
  #
  # ==== Parameters
  # isbn<String>::
  #   The ISBN of the book to find.
  named_scope :with_isbn, lambda { |isbn| {:conditions => "`books`.isbn = #{ISBNTools.normalize_isbn(isbn)}"}}
  
  ##
  # Returns the set of books ordered by their title.
  named_scope :ordered_by_title, :order => '`books`.title ASC'
  
  #--
  # Class Methods
  #++
  class << self
    ##
    # Finds a book based on its ISBN. Only looks in the local database.
    #
    # ==== Parameters
    # isbn<Sring>::
    #   The ISBN of the book to find.
    #
    # ==== Returns
    # Book::
    #   The book corresponding to the given ISBN.
    def find_by_isbn(isbn, options={})
      self.with_isbn(isbn).find(:first, options)
    end
    
    ##
    # Finds a book based on its ISBN. Looks first in the local database, then in
    # the remote ISBNdb database.
    #
    # ==== Parameters
    # isbn<Sring>::
    #   The ISBN of the book to find.
    #
    # ==== Returns
    # Book::
    #   The book corresponding to the given ISBN.
    def find_or_initialize_by_isbn(isbn)
      if book = self.find_by_isbn(isbn)
        book
      else
        normalized_isbn = ISBNTools.normalize_isbn(isbn)
        
        response = Net::HTTP.get_response(URI.parse(
          "http://ecs.amazonaws.com/onca/xml" +
          "?Service=AWSECommerceService" +
          "&AWSAccessKeyId=1BMBAZ46FKSDFTW08FR2" +
          "&Operation=ItemLookup" +
          "&IdType=ISBN" +
          "&SearchIndex=Books" +
          "&ResponseGroup=Medium" +
          "&ItemId=#{normalized_isbn}"
        ))
        
        if response.code == '200'
          data = XmlSimple.xml_in(response.body)
          data = data['Items'][0]['Item'][0]
          
          Book.new do |book|
            book.isbn  = normalized_isbn
            book.title = data['ItemAttributes'][0]['Title'][0]
            book.photo = URLTempfile.new(data['MediumImage'][0]['URL'][0])
            data['ItemAttributes'][0]['Author'].each do |author|
              book.authors.push(Author.find_or_initialize_by_name(author))
            end
          end
        else
          raise LookupFailedError
        end
      end
    end
    
    ##
    # Finds all books by a given author.
    #
    # ==== Parameters
    # author<String>::
    #   The author to query for.
    #
    # ==== Returns
    # Array::
    #   An array of Book models whose author list matches the given author.
    def search_by_author(author)
      returning([]) do |books|
        Author.find_by_contents(author, :include => :books).each { |author| books << author.books }
        books.flatten!
      end
    end
    
    ##
    # Finds all books with a given title.
    #
    # ==== Parameters
    # title<String>::
    #   The title to query for.
    #
    # ==== Returns
    # Array::
    #   An array of Book models whose title match the given title.
    def search_by_title(title)
      self.find_by_contents(title, :include => :authors, :order => '`books`.title ASC').flatten
    end
  end
  
  ##
  # Sets up Author models associated with this book from an input hash.
  #
  # ==== Parameters
  # author_attributes<Array>::
  #   The array of all the authors who contributed to this book.
  def author_attributes=(author_attributes)
    author_attributes.each do |attributes|
      self.authors.push(Author.find_or_initialize_by_name(attributes[:name])) unless attributes[:name].blank?
    end
  end
  
  ##
  # ==== Returns
  # String::
  #   The singular or plural form of the label 'Author'.
  #
  # ==== Notes
  # This method is used in form labels to correctly pluralize the label based on
  # the number of authors for this book. It's here mostly because I can't stand
  # the 'Author(s)' convention.
  def author_label_text
    (self.authors.size > 1) ? 'Author'.pluralize : 'Author'
  end
  
  ##
  # ==== Returns
  # String::
  #   The list of the authors of this book, separated by commas and truncated
  #   to 60 characters.
  def authors_with_formatting
    ActionController::Base.helpers.truncate(self.authors.join(', '), 60)
  end
  
  ##
  # ==== Returns
  # String::
  #   The average price this book is listed for.
  def average_price
    ActionController::Base.helpers.number_to_currency(
      Post.average(:price, :conditions => [
        "posts.book_id = ? AND posts.state = 'for_sale'", self.id
      ])
    )
  end
  
  ##
  # ==== Returns
  # String::
  #   The average price this book has been sold for.
  def average_sold_price
    ActionController::Base.helpers.number_to_currency(
      Post.average(:price, :conditions => [
        "posts.book_id = ? AND posts.state = 'sold'", self.id
      ])
    )
  end
  
  ##
  # Set's the isbn attribute for this book.
  #
  # ==== Parameters
  # isbn<String>::
  #   The ISBN for this book.
  #
  # ==== Notes
  # This method passes the given ISBN off to the ISBNTools module to be
  # normalized. If it fails that, it sets the isbn attribute to nil.
  def isbn=(isbn)
    begin
      self[:isbn] = ISBNTools.normalize_isbn(isbn)
    rescue ISBNTools::InvalidISBN
      self[:isbn] = nil
    end
  end
  
  ##
  # ==== Returns
  # String::
  #   The ISBN of this book, neatly hyphenated.
  def isbn_with_formatting
    ISBNTools::hyphenate_isbn13(self.isbn)
  end
  
  ##
  # ==== Returns
  # String::
  #   The lowest price listed for this book.
  def lowest_price
    number_to_currency(
      Post.minimum(:price, :conditions => [
        "posts.book_id = ? AND posts.state = 'for_sale'", self.id
      ])
    )
  end
  
  ##
  # ==== Returns
  # String::
  #   The title of the book, truncated to 50 characters.
  def title_with_formatting
    ActionController::Base.helpers.truncate(self.title, 50)
  end
  
  ##
  # ==== Returns
  # String::
  #   The title of the book.
  def to_s
    self.title
  end
end
