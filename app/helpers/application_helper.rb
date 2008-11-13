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
  
  def page_title
    case params[:controller]
      when 'posts'
        case params[:action]
          when 'index'   then 'View Your Posts'
          when 'edit'    then 'Edit Your Post'
          when 'new'     then 'Add a New Post'
          when 'review'  then 'Edit Your New Post'
          when 'confirm' then 'Confirm Your Purchase'
        end
      when 'books'
        case params[:action]
          when 'index'  then 'Find a Book'
          when 'search' then 'Find a Book'
          when 'show'   then 'Pick a Book'
        end
      when 'main'
        case params[:action]
          when 'index'   then 'Welcome'
          when 'about'   then 'About CSX'
          when 'terms'   then 'Terms of Use'
          when 'privacy' then 'Privacy Policy'
          when 'contact' then 'Contact Us'
        end
      when 'accounts'
        case params[:action]
          when 'new'  then 'Register With the Book Connection'
          when 'edit' then 'Edit Your Account'
        end
      when 'sessions'
        case params[:action]
          when 'new' then 'Login'
        end
    end
  end
  
  def error_messages_for(*params)
    options = params.extract_options!.symbolize_keys
    
    if object = options.delete(:object)
      objects = [object].flatten
    else
      objects = params.collect { |object_name| instance_variable_get("@#{object_name}") }.compact
    end
    
    count = objects.inject(0) { |sum, object| sum + object.errors.count }
    
    unless count.zero?
      flash.now[:errors] = "There are errors in your form."
    end
  end
  
  def text_or_error_message_on(alternate_text, object, method, prepend_text = "", append_text = "", css_class = "formError")
    if (obj = (object.respond_to?(:errors) ? object : instance_variable_get("@#{object}"))) && errors = obj.errors.on(method)
      content_tag("div", "#{prepend_text}#{errors.is_a?(Array) ? errors.first : errors}#{append_text}", :class => css_class)
    else
      alternate_text
    end
  end
end
