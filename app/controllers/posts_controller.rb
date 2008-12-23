class PostsController < ApplicationController # :nodoc:
  def index
    @posts = self.current_user.posts.ordered_by_title
  end
  
  def review
    begin
      @post = Post.new
      @book = Book.find_or_initialize_by_isbn(params[:book][:isbn])
    rescue Book::LookupFailedError
      @book = Book.new(:isbn => params[:book][:isbn])
      @book.authors.build
      render(:action => 'create')
    rescue ISBNTools::InvalidISBN
      flash[:warning] = $!.to_s
      redirect_to(new_post_path)
    end
  end
  
  def create
    if params[:user_created_book]
      @book = Book.create(params[:book])
    else
      @book = Book.find_or_initialize_by_isbn(params[:book][:isbn])
      @book.save
    end
    
    @post = Post.new do |post|
      post.user         = self.current_user
      post.book         = @book
      post.edition      = params[:post][:edition]
      post.condition_id = params[:post][:condition_id]
      post.price        = params[:post][:price]
    end
    
    if @post.save
      flash[:notice] = "\"#{@template.truncate(@book.title, :length => 50)}\" was added to your posted books."
      redirect_to(posts_path)
    else
      if params[:user_created_book]
        render(:action => 'create')
      else
        render(:action => 'review')
      end
    end
  end
  
  def edit
    @post = Post.find(params[:id], :include => { :book => :authors })
  end
  
  def update
    @post = Post.find(params[:id], :include => [ :book ])
    
    if @post.update_attributes(params[:post])
      flash[:notice] = "\"#{@template.truncate(@post.book.title, :length => 50)}\" was successfully updated."
      redirect_to(posts_path)
    else
      render(:action => 'edit')
    end
  end
  
  def confirm
    @post = Post.find(params[:id], :include => [ :book, :user ])
  end
  
  def purchase
    @post = Post.find(params[:id], :include => [ :book, :user ])
    
    begin
      @post.purchase(self.current_user)
    rescue Post::PostNotAvailable
      flash[:warning] = "Oops! It looks like someone bought that book moments before you. Sorry..."
      redirect_to(books_path)
    else
      PostMailer.deliver_purchased_notification(@post)
      PostMailer.deliver_sold_notification(@post)
      
      flash.now[:notice] = "You just bought \"#{@template.truncate(@post.book.title, :length => 50)}\" from #{@post.user}!"
    end
  end
  
  def relist
    post = Post.find(params[:id])
    post.list!
    
    flash[:notice] = "\"#{@template.truncate(post.book.title, :length => 50)}\" was re-listed for sale."
    redirect_to(posts_path)
  end
  
  def destroy
    @post = Post.find(params[:id])
    @post.destroy
    
    flash[:notice] = "\"#{@template.truncate(@post.book.title, :length => 50)}\" was successfully removed."
    redirect_to(posts_path)
  end
end
