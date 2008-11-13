class SessionsController < ApplicationController # :nodoc:
  skip_before_filter :require_login
  
  def create
    if params[:commit].include?('Login')
      begin
        self.current_user = User.authenticate(params[:user][:username], params[:user][:password])
      rescue
        flash[:notice] = %{
          Your account is not active. Check your email for your activation code, or
          #{@template.link_to('click here')} to get a new one.
        }
        redirect_to(new_session_path)
      else
        if logged_in?
          redirect_back_or_default(posts_path)
        else
          flash[:notice] = "Incorrect email/password combination."
          redirect_to(new_session_path)
        end
      end
    else # The user wants their password reset...
      if user = User.find_by_username(params[:user][:username])
        flash[:notice] = %{
          We just emailed your new password to your address, #{user.email}. Check your
          <a href="http://webmail.calvin.edu/">webmail</a> to retrieve it.
        }
        
        user.reset_password
        UserMailer.deliver_reset_password(user)
        
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
