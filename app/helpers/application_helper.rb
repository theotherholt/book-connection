module ApplicationHelper # :nodoc:
  def account_menu
    content_tag(:div, { :id => 'account' }) do
      if logged_in?
        %{
          Logged in as #{link_to(h(self.current_user), account_path, :class => 'focus')}
          (#{link_to('Logout', { :controller => 'sessions', :action => 'destroy' }, { :method => :delete })})
        }
      else
        %{
          Welcome guest, please #{link_to('login', new_session_path, :class => 'focus')}
          or #{link_to('register', new_account_path, :class => 'focus')}.
        }
      end
    end
  end
  
  def active?(section)
    case section
      when 'buy'
        params[:controller] == 'books' && %{ index search show }.include?(params[:action])
      when 'view'
        params[:controller] == 'posts' && %{ index show edit }.include?(params[:action])
      when 'add'
        params[:controller] == 'posts' && %{ new create review }.include?(params[:action])
    end
  end
  
  def link_for(text, section, path)
    ((active?(section)) ? '<li class="active">' : '<li>') + link_to(text, path) + '</li>'
  end
  
  def title(text)
    content_for(:title)  { "&raquo; #{text}" }
    content_for(:header) { "<h2>#{text}</h2>" }
  end
end
