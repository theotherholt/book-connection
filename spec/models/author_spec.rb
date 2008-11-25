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

describe Author, ".to_s" do
  it "should return the author's name" do
    Author.new(:name => 'Rob Bell').to_s.should eql('Rob Bell')
  end
end
