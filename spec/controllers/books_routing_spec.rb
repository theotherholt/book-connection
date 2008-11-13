require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BooksController do
  describe "route generation" do
    it "should map #index" do
      route_for(:controller => 'books', :action => 'index').should == '/books'
    end
    
    it "should map #search" do
      route_for(:controller => 'books', :action => 'search').should == '/books/search'
    end
    
    it "should map #show" do
      route_for(:controller => 'books', :action => 'show', :id => 1).should == '/books/1'
    end
  end

  describe "route recognition" do
    it "should generate params for #index" do
      params_from(:get, '/books').should == {:controller => 'books', :action => 'index'}
    end
    
    it "should generate params for #search" do
      params_from(:get, '/books/search').should == {:controller => 'books', :action => 'search'}
    end
    
    it "should generate params for #show" do
      params_from(:get, '/books/1').should == {:controller => 'books', :action => 'show', :id => '1'}
    end
  end
end
