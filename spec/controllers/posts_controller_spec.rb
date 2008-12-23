require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PostsController do
  describe "handling GET /posts" do
    fixtures :posts, :users
    
    before do
      controller.send(:current_user=, users(:ryan_holt))
      
      unordered_posts = [
        posts(:ryan_holt_velvet_elvis),
        posts(:ryan_holt_blue_like_jazz),
        posts(:ryan_holt_sex_god)
      ]
      
      @posts = [
        posts(:ryan_holt_blue_like_jazz),
        posts(:ryan_holt_sex_god),
        posts(:ryan_holt_velvet_elvis)
      ]
      
      controller.current_user.should_receive(:posts).and_return(unordered_posts)
      unordered_posts.should_receive(:ordered_by_title).and_return(@posts)
      
      get('index')
    end
    
    it "should render the 'index' template" do
      response.should render_template('index')
    end
    
    it "should assign the requested posts to the view" do
      assigns[:posts].should eql(@posts)
    end
  end
  
  describe "handling GET /posts/new" do
    fixtures :users
    
    before do
      controller.send(:current_user=, users(:ryan_holt))
      get('new')
    end
    
    it "should render the 'new' template" do
      response.should render_template('new')
    end
  end
  
  describe "handling GET /posts/:id/edit" do
    fixtures :users
    
    before do
      controller.send(:current_user=, users(:ryan_holt))
      
      @post = mock_model(Post)
      Post.should_receive(:find).with('1', :include => { :book => :authors }).and_return(@post)
      
      get('edit', :id => '1')
    end
    
    it "should render the 'edit' template" do
      response.should render_template('edit')
    end
    
    it "should assign the requested post to the view" do
      assigns[:post].should eql(@post)
    end
  end
  
  describe "handling POST /posts/new/review" do
    fixtures :users, :books
    
    describe "with a valid ISBN" do
      before do
        controller.send(:current_user=, users(:ryan_holt))
        
        @post = mock_model(Post)
        Post.should_receive(:new).and_return(@post)
        
        @book = books(:velvet_elvis)
        Book.should_receive(:find_or_initialize_by_isbn).with('9780310273080').and_return(@book)
        
        post('review', :book => { :isbn => '9780310273080' })
      end
      
      it "should render the 'review' template" do
        response.should render_template('review')
      end
      
      it "should assign the new post to the view" do
        assigns[:post].should eql(@post)
      end
      
      it "should assign the new book to the view" do
        assigns[:book].should eql(@book)
      end
    end
    
    describe "with an invalid ISBN" do
      before do
        controller.send(:current_user=, users(:ryan_holt))
        
        @post = mock_model(Post)
        Post.should_receive(:new).and_return(@post)
        Book.should_receive(:find_or_initialize_by_isbn).with('9780310273081').and_raise(ISBNTools::InvalidISBN)
        
        post('review', :book => { :isbn => '9780310273081' })
      end
      
      it "should redirect to the 'new' action" do
        response.should redirect_to(new_post_path)
      end
      
      it "should assign a flash notice" do
        flash[:warning].should eql('You entered an invalid ISBN.')
      end
    end
    
    describe "when the lookup fails" do
      before do
        controller.send(:current_user=, users(:ryan_holt))
        
        @post = mock_model(Post)
        Post.should_receive(:new).and_return(@post)
        
        Book.should_receive(:find_or_initialize_by_isbn).with('9780310273081').and_raise(Book::LookupFailedError)
        @book = mock_model(Book)
        Book.should_receive(:new).with(:isbn => '9780310273081').and_return(@book)
        
        authors = []
        @book.stub!(:authors).and_return(authors)
        authors.stub!(:build).and_return([ mock_model(Author) ])
        
        post('review', :book => { :isbn => '9780310273081' })
      end
      
      it "should render the 'create' template" do
        response.should render_template('create')
      end
      
      it "should assign the new post to the view" do
        assigns[:post].should eql(@post)
      end
      
      it "should assign the new book to the view" do
        assigns[:book].should eql(@book)
      end
    end
  end
  
  describe "handling POST /books" do
    fixtures :users, :books, :posts
    
    describe "with valid data (from the review action)" do
      before do
        controller.send(:current_user=, users(:ryan_holt))
        
        @book = books(:velvet_elvis)
        Book.should_receive(:find_or_initialize_by_isbn).with('9780310273080').and_return(@book)
        
        @post = posts(:ryan_holt_velvet_elvis)
        Post.should_receive(:new).and_return(@post)
        
        post('create', :book => { :isbn => '9780310273080' }, :post => { :condition_id => 1, :price => 10.99 })
      end
      
      it "should save the post" do
        @post.save.should be_true
      end
      
      it "should redirect to the 'index' action" do
        response.should redirect_to(posts_path)
      end
      
      it "should assign a flash message" do
        flash[:notice].should eql("\"Velvet Elvis\" was added to your posted books.")
      end
    end
    
    describe "with valid data (from the create action)" do
      before do
        controller.send(:current_user=, users(:ryan_holt))
        
        @book = books(:velvet_elvis)
        Book.should_receive(:create).with(
          'isbn'  => '9780310273080', 
          'title' => 'Velvet Elvis',
          'author_attributes' => { 'name' => 'Rob Bell' }
        ).and_return(@book)
        
        @post = posts(:ryan_holt_velvet_elvis)
        Post.should_receive(:new).and_return(@post)
        
        post('create',
          :book => {
            :isbn  => '9780310273080', 
            :title => 'Velvet Elvis',
            :author_attributes => { :name => 'Rob Bell' }
          },
          :post => {
            :condition_id => 1,
            :price     => 10.99
          },
          :user_created_book => true
        )
      end
      
      it "should save the post" do
        @post.save.should be_true
      end
      
      it "should redirect to the 'index' action" do
        response.should redirect_to(posts_path)
      end
      
      it "should assign a flash message" do
        flash[:notice].should eql("\"Velvet Elvis\" was added to your posted books.")
      end
    end
    
    describe "with invalid data (from the review action)" do
      before do
        controller.send(:current_user=, users(:ryan_holt))
      end
    end
    
    describe "with invalid data (from the create action)" do
      before do
        controller.send(:current_user=, users(:ryan_holt))
      end
    end
  end
  
  #--
  # More tests neeeded...
  #++
end
