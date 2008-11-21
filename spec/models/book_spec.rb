require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Book, "validations" do
  it do
    Book.new.should validate_presence_of(:isbn)
  end
  
  it do
    Book.new.should validate_presence_of(:title)
  end
  
  it do
    Book.new.should validate_uniqueness_of(:isbn)
  end
end

describe Book, "associations" do
  it do
    Book.new.should have_and_belong_to_many(:authors)
  end
end

describe Book, ".with_isbn scope" do
  it "should limit the result set to books with a given ISBN" do
    Book.with_isbn('9780964729230').proxy_options.should == {:conditions => "`books`.isbn = 9780964729230"}
  end
end

describe Book, ".find_or_initialize_by_isbn" do
  describe "with a valid ISBN" do
    fixtures :books, :authors
    
    before do
      @book = Book.find_or_initialize_by_isbn('9780310273080')
    end
    
    it "should return a valid Book object" do
      @book.should be_an_instance_of(Book)
    end
    
    it "should normalize the ISBN" do
      ISBNTools.should_receive(:normalize_isbn).at_least(1).and_return('9780310273080')
      Book.find_or_initialize_by_isbn('0310273080')
    end
    
    it "should populate the book's ISBN" do
      @book.isbn.should eql('9780310273080')
    end
    
    it "should populate the book's title" do
      @book.title.should eql('Velvet Elvis')
    end
    
    it "should populate the book's authors" do
      @book.authors.first.name.should eql('Rob Bell')
    end
    
    it "should populate the book's photo" do
      @book.photo.url.should_not be_nil
    end
    
    it "should not save the book" do
      Book.should_not_receive(:save)
      Book.find_or_initialize_by_isbn('9780310273080')
    end
  end
  
  describe "with a book that already exists in the local database" do
    fixtures :books
    
    before do
      @book = books(:velvet_elvis)
    end
    
    it "should not query ISBNdb" do
      Net::HTTP.should_not_receive(:get_response)
      Book.find_or_initialize_by_isbn('9780310273080')
    end
    
    it "should find it in the local database" do
      Book.should_receive(:find_by_isbn).with('9780310273080').and_return(@book)
      Book.find_or_initialize_by_isbn('9780310273080')
    end
    
    after do
      @book.destroy
    end
  end
  
  describe "with a book that does not exist in the local database" do
    before(:all) do
      @xml = File.read("#{RAILS_ROOT}/spec/fixtures/the_shack.xml")
    end
    
    it "should not be able to find it in the local database" do
      # Book.should_receive(:find_by_isbn).with('9780964729230').and_return(nil)
      # Book.find_or_initialize_by_isbn('9780964729230')
    end
    
    it "should query ISBNdb" do
      # Net::HTTP.should_receive(:get_response).once.and_return(mock_model(Net::HTTPResponse, :code => '200', :body => @xml))
      # Book.find_or_initialize_by_isbn('9780964729230')
    end
  end
  
  describe "with a failed connection to ISBNdb" do
    it "should raise the LookupFailedError exception" do
      Net::HTTP.stub!(:get_response).and_return(mock_model(Net::HTTPResponse, :code => '500'))
      lambda { Book.find_or_initialize_by_isbn('0964729237') }.should raise_error(Book::LookupFailedError)
    end
  end
end

describe Book, ".lowest_price" do
  fixtures :books
  
  it "should format the lowest price as currency" do
    ActionController::Base.helpers.should_receive(:number_to_currency).with(10.99).and_return('$10.99')
    books(:velvet_elvis).lowest_price
  end
  
  it "should return the price of the book with the lowest price" do
    books(:velvet_elvis).lowest_price.should eql('$10.99')
  end
end

describe Book, ".authors_with_formatting" do
  fixtures :books
  
  it "should return a string containing each of the book's authors separated by commas" do
    books(:programming_ruby).authors_with_formatting.should eql('Dave Thomas, Chad Fowler, Andy Hunt')
  end
end

describe Book, ".title_with_formatting" do
  it "should truncate the book's title to 50 characters" do
    Book.new(:title => 'Lorem Ipsum Dolor Sit Amet Consectetur Adipisicing Elit').title_with_formatting.should eql('Lorem Ipsum Dolor Sit Amet Consectetur Adipisic...')
  end
end

describe Book, ".to_s" do
  it "should return the book's title" do
    Book.new(:title => 'Velvet Elvis').to_s.should eql('Velvet Elvis')
  end
end