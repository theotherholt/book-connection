module PostsHelper # :nodoc:
  def add_author_link
    link_text = image_tag('add.png', { :style => 'vertical-align: top' }) + ' Add Another Author'
    link_to_function(link_text, { :class => 'add' }) do |page|
      page.insert_html(:bottom, :authors, :partial => 'author_field', :object => Author.new)
    end
  end
  
  def authors
    if @book.authors.empty?
      [ Author.new ]
    else
      @book.authors
    end
  end
end
