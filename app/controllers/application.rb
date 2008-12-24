class ApplicationController < ActionController::Base # :nodoc:
  include ExceptionNotifiable
  
  ##
  # Starts the authentication and authorization process.
  before_filter :require_login
  
  ##
  # See ActionController::RequestForgeryProtection for details.
  protect_from_forgery
  
  ##
  # Sets up the proper hostname so that the mailer can generate a full and
  # valid URL for the activation email.
  before_filter { |controller| ActionMailer::Base.default_url_options[:host] = controller.request.host_with_port }
  
  ##
  # Filters sensitive data out of the logs.
  filter_parameter_logging :password, :password_confirmation
  
  ##
  # Saves the address of the page the user wanted to get to and redirects to
  # the login page if the user isn't logged in.
  def require_login
    unless logged_in?
      session[:request_uri] = request.request_uri
      redirect_to(new_session_path)
    end
  end
  
  hide_action(:require_login)
  
  ##
  # Allows controllers to access the current_user variable. This method will load the user from
  # the session if it can, otherwise it will return the anonymous user object.
  #
  # ==== Returns
  # User::
  #   The currently logged in user, or an anonymous user.
  def current_user
    if !@current_user.nil?
      @current_user
    elsif !session[:current_user_id].nil?
      begin
        @current_user = User.find(session[:current_user_id])
      rescue ActiveRecord::RecordNotFound
        @current_user = nil
      end
    end
  end
  
  hide_action(:current_user)
  helper_method(:current_user)
  
  ##
  # ==== Parameters
  # user<User>::
  #   The current user object.
  def current_user=(user)
    unless user.nil?
      session[:current_user_id] ||= user.id
      @current_user = user
    end
  end
  
  hide_action(:current_user=)
  helper_method(:current_user=)
  
  ##
  # ==== Returns
  # Boolean::
  #   True if the currently logged in user is a registered user and is active.
  def logged_in?
    !self.current_user.nil? && self.current_user.active?
  end
  
  hide_action(:logged_in?)
  helper_method(:logged_in?)
  
  #--
  # Protected Methods
  #++
  protected
  
  ##
  # Redirects the user to the last requested URI if it exists. Otherwise redirects to the given
  # default.
  #
  # ==== Parameters
  # default<String>::
  #   The URI to redirect to if the last requested URI is not set.
  def redirect_back_or_default(default)
    redirect_to(session[:request_uri] || default)
    session[:request_uri] = nil
  end
end
