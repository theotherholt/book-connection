module PostsHelper # :nodoc:
  def add_author_link
    link_text = image_tag('add.png', { :style => 'vertical-align: top' }) + ' Add Another Author'
    link_to_function(link_text) do |page|
      page.insert_html(:bottom, :authors, :partial => 'author', :object => Author.new)
    end
  end
end
