require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe PostsController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => 'posts', :action => 'index').should == '/posts'
    end
    
    it "should map #new" do
      route_for(:controller => 'posts', :action => 'new').should == '/posts/new'
    end
    
    it "should map #review" do
      route_for(:controller => 'posts', :action => 'review').should == '/posts/new/review'
    end
    
    it "should map #edit" do
      route_for(:controller => 'posts', :action => 'edit', :id => 1).should == '/posts/1/edit'
    end
    
    it "should map #update" do
      route_for(:controller => 'posts', :action => 'update', :id => 1).should == '/posts/1'
    end
    
    it "should map #purchase" do
      route_for(:controller => 'posts', :action => 'purchase', :id => 1).should == '/posts/1/purchase'
    end
    
    it "should map #destroy" do
      route_for(:controller => 'posts', :action => 'destroy', :id => 1).should == '/posts/1/destroy'
    end
  end
  
  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, '/posts').should == {:controller => 'posts', :action => 'index'}
    end
    
    it "should generate params for #new" do
      params_from(:get, '/posts/new').should == {:controller => 'posts', :action => 'new'}
    end
    
    it "should generate params for #review" do
      params_from(:post, '/posts/new/review').should == {:controller => 'posts', :action => 'review'}
    end
    
    it "should generate params for #create" do
      params_from(:post, '/posts').should == {:controller => 'posts', :action => 'create'}
    end
    
    it "should generate params for #edit" do
      params_from(:get, '/posts/1/edit').should == {:controller => 'posts', :action => 'edit', :id => '1'}
    end
    
    it "should generate params for #update" do
      params_from(:put, '/posts/1').should == {:controller => 'posts', :action => 'update', :id => '1'}
    end
    
    it "should generate params for #purchase" do
      params_from(:post, '/posts/1/purchase').should == {:controller => 'posts', :action => 'purchase', :id => '1'}
    end
    
    it "should generate params for #destroy" do
      params_from(:delete, '/posts/1/destroy').should == {:controller => 'posts', :action => 'destroy', :id => '1'}
    end
  end
end
