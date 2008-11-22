class BooksController < ApplicationController # :nodoc:
  skip_before_filter :require_login
  
  def search
    unless params[:query].blank?
      begin
        book = Book.find_by_isbn(params[:query], :include => [ :authors, :posts ])
      rescue ISBNTools::InvalidISBN
        # Do nothing...
      ensure
        if book
          @books = [ book ]
        else
          @books = Book.search(params[:query], :include => [ :authors, :posts ], :page => params[:page])
        end
      end
      
      if @books.empty?
        flash[:warning] = "No books matched your search terms."
      end
    end
    
    render(:action => 'index')
  end
  
  def show
    @book = Book.find(params[:id], :include => [ :authors ])
  end
  
  def validate_isbn
    if request.xhr?
      begin
        ISBNTools.normalize_isbn(params[:isbn])
      rescue ISBNTools::InvalidISBN
        render(:update) { |page| page.hide('valid_isbn') }
      else
        render(:update) { |page| page.show('valid_isbn') }
      end
    end
  end
end
