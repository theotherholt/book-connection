require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Author, "validations" do
  it do
    Author.new.should validate_presence_of(:name)
  end
end

describe Author, "associations" do
  it do
    Author.new.should have_and_belong_to_many(:books)
  end
end

describe Author, ".find_by_contents" do
  fixtures :authors
  
  it "should find 'Rob Bell' given 'rob'" do
    Author.find_by_contents('rob').first.should eql(authors(:rob_bell))
  end
  
  it "should find 'Rob Bell' given 'bell'" do
    Author.find_by_contents('bell').first.should eql(authors(:rob_bell))
  end
end

describe Author, ".to_s" do
  it "should return the author's name" do
    Author.new(:name => 'Rob Bell').to_s.should eql('Rob Bell')
  end
end
