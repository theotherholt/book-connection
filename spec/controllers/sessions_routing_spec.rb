require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SessionsController do
  describe "route generation" do
    it "should map #new" do
      route_for(:controller => 'sessions', :action => 'new').should == '/session/new'
    end
    
    it "should map #create" do
      route_for(:controller => 'sessions', :action => 'create').should == '/session'
    end
  end

  describe "route recognition" do
    it "should generate params for #new" do
      params_from(:get, '/session/new').should == {:controller => 'sessions', :action => 'new'}
    end
    
    it "should generate params for #create" do
      params_from(:post, '/session').should == {:controller => 'sessions', :action => 'create'}
    end
  end
end
