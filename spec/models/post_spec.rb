require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Post, "validations" do
  it do
    Post.new.should validate_presence_of(:user_id)
  end
  
  it do
    Post.new.should validate_presence_of(:book_id)
  end
  
  it do
    Post.new.should validate_presence_of(:condition_id)
  end
  
  it do
    Post.new.should validate_presence_of(:price)
  end
  
  it do
    Post.new.should validate_numericality_of(:price)
  end
  
  it do
    Post.new.should validate_numericality_of(:edition)
  end
end

describe Post, "associations" do
  it do
    Post.new.should belong_to(:user)
  end
  
  it do
    Post.new.should belong_to(:book)
  end
  
  it do
    Post.new.should belong_to(:buyer)
  end
end

describe Post, "ordered_by_title scope" do
  fixtures :books, :posts
  
  it "should return a list of posts ordered by their associated book's title" do
    ordered_posts = [
      posts(:ryan_holt_blue_like_jazz),
      posts(:ryan_holt_sex_god),
      posts(:ryan_holt_velvet_elvis)
    ]
    
    Post.ordered_by_title.should eql(ordered_posts)
  end
end

describe Post, "ordered_by_price scope" do
  fixtures :posts
  
  it "should return a lists of posts ordered by their price" do
    ordered_posts = [
      posts(:ryan_holt_sex_god),
      posts(:ryan_holt_blue_like_jazz),
      posts(:ryan_holt_velvet_elvis)
    ]
    
    Post.ordered_by_price.should eql(ordered_posts)
  end
end

describe Post, "for_sale scope" do
  fixtures :posts
  
  it "should return a list of posts that are for sale" do
    posts_for_sale = [
      posts(:ryan_holt_blue_like_jazz),
      posts(:ryan_holt_velvet_elvis)
    ]
    
    Post.for_sale.should eql(posts_for_sale)
  end
end

describe Post, ".condition_with_formatting" do
  it "should return 'New' when condition is set to 1" do
    Post.new(:condition_id => 1).condition_with_formatting.should eql('New')
  end
  
  it "should return 'Almost New' when condition is set to 2" do
    Post.new(:condition_id => 2).condition_with_formatting.should eql('Almost New')
  end
  
  it "should return 'Used' when condition is set to 3" do
    Post.new(:condition_id => 3).condition_with_formatting.should eql('Used')
  end
  
  it "should return 'Worn' when condition is set to 4" do
    Post.new(:condition_id => 4).condition_with_formatting.should eql('Worn')
  end
  
  it "should return 'Damaged' when condition is set to 5" do
    Post.new(:condition_id => 5).condition_with_formatting.should eql('Damaged')
  end
end

describe Post, ".edition_with_formatting" do
  it "should return 'N/A' if no edition is set" do
    Post.new.edition_with_formatting.should eql('N/A')
  end
  
  it "should ordinalize edition if edition is set" do
    Post.new(:edition => 1).edition_with_formatting.should eql('1st')
  end
end

describe Post, ".edition=" do
  it "should clean up the edition if it contains valid number" do
    post = Post.new(:edition => '1st')
    post.should have(:no).errors_on(:edition)
    post.edition.should == 1
  end
  
  it "should let Rails handle error checking if the edition does not contain a valid number" do
    post = Post.new(:edition => 'not a number')
    post.should have(1).error_on(:edition)
  end
end

describe Post, ".list!" do
  fixtures :posts
  
  before do
    @post = posts(:ryan_holt_velvet_elvis)
    @post.list!
  end
  
  it "should set sold_at to nil" do
    @post.sold_at.should be_nil
  end
  
  it "should set the buyer to nil" do
    @post.buyer.should be_nil
  end
  
  it "should increment the associated book's posts_for_sale_count" do
    post = posts(:ryan_holt_velvet_elvis)
    previous_count = post.book.posts_for_sale_count
    lambda { post.list! }.should change(post.book, :posts_for_sale_count).from(previous_count).to(previous_count + 1)
  end
end

describe Post, ".price_with_formatting" do
  it "should return the price formatted as currency" do
    Post.new(:price => 15.99).price_with_formatting.should eql('$15.99')
  end
end

describe Post, ".price=" do
  it "should clean up the price if it contains valid number" do
    post = Post.new(:price => '$15.99')
    post.should have(:no).errors_on(:price)
    post.price.should eql(15.99)
  end
  
  it "should let Rails handle error checking if the price does not contain a valid number" do
    post = Post.new(:price => 'not a number')
    post.should have(1).error_on(:price)
  end
end

describe Post, ".purchase" do
  fixtures :users, :posts
  
  before do
    @post = posts(:ryan_holt_velvet_elvis)
  end
  
  it "should raise PostNotAvailable if the post has already been sold" do
    @post.update_attribute(:sold_at, Time.now)
    lambda { @post.purchase(users(:ryan_holt)) }.should raise_error(Post::PostNotAvailable)
  end
  
  it "should set the buyer" do
    lambda { @post.purchase(users(:ryan_holt)) }.should change(@post, :buyer).to(users(:ryan_holt))
  end
  
  it "should set the sold_at time" do
    lambda { @post.purchase(users(:ryan_holt)) }.should change(@post, :sold_at)
  end
  
  it "should decrement the associated book's posts_for_sale_count" do
    previous_count = @post.book.posts_for_sale_count
    lambda { @post.purchase(users(:ryan_holt)) }.should change(@post.book, :posts_for_sale_count).from(previous_count).to(previous_count - 1)
  end
end

describe Post, ".sold?" do
  it "should be true if sold_at is set" do
    Post.new(:sold_at => Time.now).sold?.should be_true
  end
  
  it "should be false if sold_at is nil" do
    Post.new(:sold_at => nil).sold?.should be_false
  end
end

describe Post, ".state_with_formatting" do
  it "should humanize the state" do
    Post.new(:sold_at => nil).state_with_formatting.should eql('For sale')
    Post.new(:sold_at => Time.now).state_with_formatting.should eql('Sold')
  end
end
