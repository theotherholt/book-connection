class BooksController < ApplicationController # :nodoc:
  skip_before_filter :require_login
  
  def search
    case params[:type]
    when 'isbn'
      begin
        book = Book.find_by_isbn(params[:query], :include => [ :authors, :posts ])
      rescue ISBNTools::InvalidISBN
        flash[:warning] = $!.to_s
        redirect_to(books_path) && return
      else
        @books = [ book ].compact
      end
      
      if @books.empty? || @books.all? { |book| book.posts.for_sale.empty? }
        flash.now[:warning] = "We couldn't find any books with the ISBN #{params[:query]}."
      end
    when 'title'
      @books = Book.search_by_title(params[:query])
      
      if @books.empty? || @books.all? { |book| book.posts.for_sale.empty? }
        flash.now[:warning] = "We couldn't find any books with the title \"#{params[:query]}\"."
      end
    when 'author'
      @books = Book.search_by_author(params[:query])
      
      if @books.empty? || @books.all? { |book| book.posts.for_sale.empty? }
        flash.now[:warning] = "We couldn't find any books by authors with the name \"#{params[:query]}\"."
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
