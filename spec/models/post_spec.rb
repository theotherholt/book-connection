require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Post, "validations" do
  it do
    Post.new.should validate_presence_of(:price)
  end
  
  it do
    Post.new.should validate_numericality_of(:price)
  end
  
  it do
    Post.new.should validate_presence_of(:condition_id)
  end
  
  it do
    Post.new.should validate_numericality_of(:edition)
  end
end

describe Post, "associations" do
  it do
    Post.new.should belong_to(:book)
  end
  
  it do
    Post.new.should belong_to(:user)
  end
  
  it do
    Post.new.should belong_to(:buyer)
  end
end

describe Post, "ordered_by_title scope" do
  fixtures :users, :posts
  
  it "should return the list of posts ordered by their associated book's title" do
    ordered_posts = [
      posts(:ryan_holt_blue_like_jazz),
      posts(:ryan_holt_sex_god),
      posts(:ryan_holt_velvet_elvis)
    ]
    Post.ordered_by_title.find_all_by_user_id(users(:ryan_holt).id).should eql(ordered_posts)
  end
end

describe Post, "ordered_by_state scope" do
  fixtures :users, :posts
  
  it "should return a list of posts ordered by their state" do
    ordered_posts = [
      posts(:ryan_holt_blue_like_jazz),
      posts(:ryan_holt_velvet_elvis),
      posts(:ryan_holt_sex_god)
    ]
    Post.ordered_by_state.find_all_by_user_id(users(:ryan_holt).id).should eql(ordered_posts)
  end
end

describe Post, "ordered_by_price scope" do
  fixtures :users, :posts
  
  it "should return a lists of posts ordered by their price" do
    ordered_posts = [
      posts(:ryan_holt_sex_god),
      posts(:ryan_holt_blue_like_jazz),
      posts(:ryan_holt_velvet_elvis)
    ]
    Post.ordered_by_price.find_all_by_user_id(users(:ryan_holt).id).should eql(ordered_posts)
  end
end

describe Post, "for_sale scope" do
  fixtures :users, :posts
  
  it "should return a list of posts that are for sale" do
    posts_for_sale = [
      posts(:ryan_holt_blue_like_jazz),
      posts(:ryan_holt_velvet_elvis)
    ]
    Post.for_sale.find_all_by_user_id(users(:ryan_holt).id).should eql(posts_for_sale)
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
    post.edition.should eql(1)
  end
end

describe Post, ".price_with_formatting" do
  it "should return a formatted price if a valid price is set" do
    Post.new(:price => 15.99).price_with_formatting.should eql('$15.99')
  end
end

describe Post, ".price=" do
  it "should clean up the price if it contains valid number" do
    post = Post.new(:price => '$15.99')
    post.should have(:no).errors_on(:price)
    post.price.should eql(15.99)
  end
end

describe Post, ".purchase" do
end

describe Post, ".state_with_formatting" do
  it "should humanize the state" do
    Post.new(:state => 'passive').state_with_formatting.should eql('Passive')
    Post.new(:state => 'for_sale').state_with_formatting.should eql('For sale')
    Post.new(:state => 'sold').state_with_formatting.should eql('Sold')
    Post.new(:state => 'unavailable').state_with_formatting.should eql('Unavailable')
  end
end

describe Post, ".status" do
  it "should return true if the post's state is 'for_sale'" do
    Post.new(:state => 'for_sale').status.should be_true
  end
  
  it "should return false if the post's state is not 'for_sale'" do
    Post.new(:state => 'unavailable').status.should be_false
  end
end

describe Post, ".status=" do
  fixtures :posts
  
  before do
    @post = posts(:ryan_holt_velvet_elvis)
  end
  
  it "should unlist the post if set to 0" do
    @post.should_receive(:unlist!).and_return(true)
    @post.status = 0
  end
  
  it "should list the post if set to 1" do
    @post.should_receive(:list!).and_return(true)
    @post.status = 1
  end
end