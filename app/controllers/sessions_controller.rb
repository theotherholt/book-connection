class SessionsController < ApplicationController # :nodoc:
  skip_before_filter :require_login
  skip_before_filter :verify_authenticity_token
  
  def index
    redirect_to(new_session_path)
  end
  
  def create
    if params[:commit].include?('Login')
      begin
        self.current_user = User.authenticate(params[:user][:username], params[:user][:password])
      rescue User::AccountNotVerified
        flash[:warning] = %{
          Your account is not active. Check your email for your activation code, or
          #{@template.link_to('click here', reset_activation_path)}
          to get a new one.
        }
        redirect_to(new_session_path)
      else
        if logged_in?
          redirect_back_or_default(posts_path)
        else
          flash[:warning] = "Incorrect username/password combination."
          redirect_to(new_session_path)
        end
      end
    else # The user wants their password reset...
      if user = User.find_by_username(params[:user][:username])
        user.reset_password
        UserMailer.deliver_reset_password(user)
        
        flash[:notice] = %{
          We just emailed your new password to your address, #{user.email}. Check your
          #{@template.link_to('webmail', 'http://www.calvin.edu/go/studentmail/')} to retrieve it.
        }
        redirect_to(new_session_path)
      else
        flash[:notice] = "We couldn't find an account with that username."
        redirect_to(new_session_path)
      end
    end
  end
  
  def destroy
    reset_session
    redirect_to(root_path)
  end
end
