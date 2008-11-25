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
    describe "when the user submits a blank form" do
      before do
        get('search', :query => '')
      end
      
      it "should render the 'index' template" do
        response.should render_template('index')
      end
    end
    
    describe "when the user submits an ISBN" do
      describe "for an existing book" do
        fixtures :books
        
        before do
          @book = books(:velvet_elvis)
          Book.should_receive(:find_by_isbn).with('9780310273080', :include => [ :authors, :posts ]).and_return(@book)
          get('search', :query => '9780310273080')
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
          Book.should_receive(:search).with('9780310273080', :include => [ :authors, :posts ], :page => params[:page]).and_return([])
          get('search', :query => '9780310273080')
        end
        
        it "should render the 'index' template" do
          response.should render_template('index')
        end
        
        it "should set a flash message" do
          flash[:warning].should eql("No books matched your search terms.")
        end
        
        it "should assign an array containing no books to the view" do
          assigns[:books].should eql([])
        end
      end
      
      describe "for an invalid ISBN" do
        before do
          Book.should_receive(:find_by_isbn).with('9780310273081', :include => [ :authors, :posts ]).and_raise(ISBNTools::InvalidISBN)
          Book.should_receive(:search).with('9780310273081', :include => [ :authors, :posts ], :page => params[:page]).and_return([])
          get('search', :type => 'isbn', :query => '9780310273081')
        end
        
        it "should render the 'index' template" do
          response.should render_template('index')
        end
        
        it "should set a flash message" do
          flash[:warning].should eql("No books matched your search terms.")
        end
        
        it "should assign an array containing no books to the view" do
          assigns[:books].should eql([])
        end
      end
    end
    
    describe "when the user submits a book title" do
      describe "for an existing book" do
        fixtures :books
        
        before do
          @book = books(:velvet_elvis)
          Book.should_receive(:find_by_isbn).with('velvet', :include => [ :authors, :posts ]).and_raise(ISBNTools::InvalidISBN)
          Book.should_receive(:search).with('velvet', :include => [ :authors, :posts ], :page => params[:page]).and_return([@book])
          get('search', :query => 'velvet')
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
          Book.should_receive(:find_by_isbn).with('foo', :include => [ :authors, :posts ]).and_raise(ISBNTools::InvalidISBN)
          Book.should_receive(:search).with('foo', :include => [ :authors, :posts ], :page => params[:page]).and_return([])
          get('search', :query => 'foo')
        end
        
        it "should render the 'index' template" do
          response.should render_template('index')
        end
        
        it "should set a flash message" do
          flash[:warning].should eql("No books matched your search terms.")
        end
        
        it "should assign an array containing no books to the view" do
          assigns[:books].should eql([])
        end
      end
    end
    
    describe "when the user submits an author's name" do
      describe "for an existing book" do
        fixtures :books
        
        before do
          @book = books(:velvet_elvis)
          Book.should_receive(:find_by_isbn).with('rob', :include => [ :authors, :posts ]).and_raise(ISBNTools::InvalidISBN)
          Book.should_receive(:search).with('rob', :include => [ :authors, :posts ], :page => params[:page]).and_return([@book])
          get('search', :query => 'rob')
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
          Book.should_receive(:find_by_isbn).with('foo', :include => [ :authors, :posts ]).and_raise(ISBNTools::InvalidISBN)
          Book.should_receive(:search).with('foo', :include => [ :authors, :posts ], :page => params[:page]).and_return([])
          get('search', :query => 'foo')
        end
        
        it "should render the 'index' template" do
          response.should render_template('index')
        end
        
        it "should set a flash message" do
          flash[:warning].should eql("No books matched your search terms.")
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
