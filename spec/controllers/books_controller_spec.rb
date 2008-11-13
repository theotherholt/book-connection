require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BooksController do
  describe "handling GET /books" do
    before do
      get('index')
    end
    
    it "should render the 'index' template" do
      response.should render_template('index')
    end
  end
  
  describe "handling GET /books/search" do
    describe "for an ISBN search" do
      describe "for an existing book" do
        fixtures :books
        
        before do
          @book = books(:velvet_elvis)
          Book.should_receive(:find_by_isbn).with('9780310273080', :include => [ :authors, :posts ]).and_return(@book)
          get('search', :type => 'isbn', :query => '9780310273080')
        end
        
        it "should render the 'index' template" do
          response.should render_template('index')
        end
        
        it "should assign an array containing the book it finds to the view" do
          assigns[:books].should eql([@book])
        end
      end
      
      describe "for a non-existant book" do
        before do
          Book.should_receive(:find_by_isbn).with('9780310273080', :include => [ :authors, :posts ]).and_return(nil)
          get('search', :type => 'isbn', :query => '9780310273080')
        end
        
        it "should render the 'index' template" do
          response.should render_template('index')
        end
        
        it "should set a flash message" do
          flash[:warning].should eql("We couldn't find any books with the ISBN 9780310273080.")
        end
        
        it "should assign no books to the view" do
          assigns[:books].should eql([])
        end
      end
      
      describe "for an invalid ISBN" do
        before do
          Book.should_receive(:find_by_isbn).with('9780310273081', :include => [ :authors, :posts ]).and_raise(ISBNTools::InvalidISBN)
          get('search', :type => 'isbn', :query => '9780310273081')
        end
        
        it "should redirect to the 'index' action" do
          response.should redirect_to(books_path)
        end
        
        it "should set a flash message" do
          flash[:warning].should eql("You entered an invalid ISBN.")
        end
        
        it "should assign no books to the view" do
          assigns[:books].should eql(nil)
        end
      end
    end
    
    describe "for a title search" do
      describe "for an existing book" do
        fixtures :books
        
        before do
          @book = books(:velvet_elvis)
          Book.should_receive(:search_by_title).with('velvet').and_return([@book])
          get('search', :type => 'title', :query => 'velvet')
        end
        
        it "should render the 'index' template" do
          response.should render_template('index')
        end
        
        it "should assign an array containing the books it finds to the view" do
          assigns[:books].should eql([@book])
        end
      end
      
      describe "for a non-existant book" do
        before do
          Book.should_receive(:search_by_title).with('velvet').and_return([])
          get('search', :type => 'title', :query => 'velvet')
        end
        
        it "should render the 'index' template" do
          response.should render_template('index')
        end
        
        it "should set a flash message" do
          flash[:warning].should eql("We couldn't find any books with the title \"velvet\".")
        end
        
        it "should assign an array containing no books to the view" do
          assigns[:books].should eql([])
        end
      end
    end
    
    describe "for an author search" do
      describe "for an existing book" do
        fixtures :books
        
        before do
          @book = books(:velvet_elvis)
          Book.should_receive(:search_by_author).with('rob').and_return([@book])
          get('search', :type => 'author', :query => 'rob')
        end
        
        it "should render the 'index' template" do
          response.should render_template('index')
        end
        
        it "should assign an array containing the books it finds to the view" do
          assigns[:books].should eql([@book])
        end
      end
      
      describe "for a non-existant book" do
        before do
          Book.should_receive(:search_by_author).with('rob').and_return([])
          get('search', :type => 'author', :query => 'rob')
        end
        
        it "should render the 'index' template" do
          response.should render_template('index')
        end
        
        it "should set a flash message" do
          flash[:warning].should eql("We couldn't find any books by authors with the name \"rob\".")
        end
        
        it "should assign an array containing no books to the view" do
          assigns[:books].should eql([])
        end
      end
    end
  end
  
  describe "handling GET /books/:id" do
    fixtures :books
    
    before do
      @book = books(:velvet_elvis)
      Book.should_receive(:find).with('1', :include => [ :authors ]).and_return(@book)
      get('show', :id => '1')
    end
    
    it "should render the 'show' template" do
      response.should render_template('show')
    end
    
    it "should assign the requested book to the view" do
      assigns[:book].should eql(@book)
    end
  end
end
