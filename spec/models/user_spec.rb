require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe User, "validations" do
  it do
    User.new.should validate_presence_of(:first_name)
  end
  
  it do
    User.new.should validate_presence_of(:last_name)
  end
  
  it do
    User.new.should validate_presence_of(:username)
  end
  
  it do
    User.new.should validate_uniqueness_of(:username)
  end
  
  it do
    User.new.should validate_length_of(:password, :minimum => 4, :maximum => 40)
  end
  
  it do
    User.new.should validate_presence_of(:password)
  end
  
  it do
    User.new.should validate_confirmation_of(:password)
  end
  
  it do
    User.new.should validate_presence_of(:password_confirmation)
  end
end

describe User, "associations" do
  it do
    User.new.should have_many(:posts)
  end
end

describe User, ".authenticate" do
  fixtures :users
  
  it "should return a user given a valid username and password combination" do
    User.authenticate('rah6', 'password').should eql(users(:ryan_holt))
  end
  
  it "should update the last_login_at field when it authenticates a user" do
    user = users(:ryan_holt)
    
    lambda {
      User.authenticate('rah6', 'password')
      user.reload # Need to update the user object's state.
    }.should change(user, :last_login_at)
  end
  
  it "should return nil if given a bad username and password combination" do
    User.authenticate('rah6', 'bad').should be_nil
  end
  
  it "should raise User::AccountNotVerified if a non-active user attempts to login" do
    users(:ryan_holt).update_attribute(:state, 'pending') # Deactivate Ryan for now.
    
    lambda {
      User.authenticate('rah6', 'password')
    }.should raise_error(User::AccountNotVerified)
  end
end

describe User, ".authenticated?" do
  fixtures :users
  
  it "should return true if the given plaintext password matches the stored encrypted password" do
    users(:ryan_holt).authenticated?('password').should be_true
  end
  
  it "should return false if the given plaintext password does not match the stored encrypted password" do
    users(:ryan_holt).authenticated?('bad').should be_false
  end
end

describe User, ".reset_password" do
  fixtures :users
  
  before do
    @user = users(:ryan_holt)
  end
  
  it "should change the password attribute" do
    lambda {
      @user.reset_password
    }.should change(@user, :password)
  end
  
  it "should change the encrypted password" do
    lambda {
      @user.reset_password
    }.should change(@user, :crypted_password)
  end
end

describe User, ".set_password" do
  fixtures :users
  
  before do
    @user = users(:ryan_holt)
  end
  
  it "should change the password attribute" do
    lambda {
      @user.set_password('foobar')
    }.should change(@user, :password)
  end
  
  it "should change the encrypted password" do
    lambda {
      @user.set_password('foobar')
    }.should change(@user, :crypted_password)
  end
end

describe User, ".update_password" do
  fixtures :users
  
  before do
    @user = users(:ryan_holt)
  end
  
  it "should update the user's password when they confirm their old password and provide matching new passwords" do
    lambda {
      @user.update_password('password', 'new_password', 'new_password').should be_true
    }.should change(@user, :crypted_password)
  end
  
  it "should do nothing if the user provides an invalid old password" do
    lambda {
      @user.update_password('bad_old_password', 'new_password', 'new_password').should be_false
    }.should_not change(@user, :crypted_password)
  end
  
  it "should do nothing if the user's new passwords do not match" do
    lambda {
      @user.update_password('test', 'one_new_password', 'another_new_password').should be_false
    }.should_not change(@user, :crypted_password)
  end
  
  it "should do nothing if the user doesn't provide a new password (i.e.: no blank passwords allowed)" do
    lambda {
      @user.update_password('old_password', nil, nil).should be_false
    }.should_not change(@user, :crypted_password)
  end
end