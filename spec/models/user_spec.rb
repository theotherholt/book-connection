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
    users(:ryan_holt).update_attribute(:activated_at, nil) # Deactivate Ryan for now.
    
    lambda {
      User.authenticate('rah6', 'password')
    }.should raise_error(User::AccountNotVerified)
  end
end

describe User, ".activate!" do
  fixtures :users
  
  it "should set the activated_at field" do
    user = users(:ryan_holt)
    lambda { user.activate! }.should change(user, :activated_at)
  end
end

describe User, ".active?" do
  it "should return true if activated_at is set" do
    user = User.new
    user.activated_at = Time.now
    user.active?.should be_true
  end
  
  it "should return false if activated_at is not set" do
    user = User.new
    user.activated_at = nil
    user.active?.should be_false
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

describe User, ".email" do
  it "should return the user's alternate email if it is set" do
    User.new(:alternate_email => 'foo@bar.com').email.should eql('foo@bar.com')
  end
  
  it "should return the user's webmail address, with an domain based on that user's alumni status" do
    User.new(:username => 'foo', :alumni => false).email.should eql('foo@students.calvin.edu')
    User.new(:username => 'foo', :alumni => true).email.should eql('foo@alumni.calvin.edu')
  end
end

describe User, ".email_with_name" do
  before do
    @user = User.new do |user|
      user.first_name = 'First'
      user.last_name  = 'Last'
      user.username   = 'foo'
      user.alumni     = false
    end
  end
  
  it "should return the user's name and email formatted as 'First Last <foo@bar.com>'" do
    @user.email_with_name.should eql('First Last <foo@students.calvin.edu>')
  end
  
  it "should call email to do the actual email formatting" do
    @user.should_receive(:email).and_return('foo@students.calvin.edu')
    @user.email_with_name
  end
end

describe User, ".name (and .to_s)" do
  it "should return the user's full name" do
    User.new(:first_name => 'Ryan', :last_name => 'Holt').name.should eql('Ryan Holt')
  end
end

describe User, ".reset_activation_code" do
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

describe User, ".suspend!" do
  fixtures :users
  
  before do
    @user = users(:ryan_holt)
  end
  
  it "should set the activated_at field to nil" do
    lambda { @user.suspend! }.should change(@user, :activated_at).to(nil)
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