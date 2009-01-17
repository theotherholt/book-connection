class AccountsController < ApplicationController # :nodoc:
  skip_before_filter :require_login, :except => [ :show, :edit, :update ]
  skip_before_filter :verify_authenticity_token, :except => [ :show, :edit, :update ]
  
  def activate
    @user = User.find_by_activation_code(params[:activation_code])
    
    if @user.nil?
      flash[:notice] = "We couldn't find an account with that activation code."
      redirect_to(root_path)
    else
      @user.activate!
      flash[:notice] = "Your account is active and ready to go!"
      redirect_to(new_session_path)
    end
  end
  
  def show
    redirect_to(edit_account_path)
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    
    if @user.save
      UserMailer.deliver_signup_notification(@user)
      
      flash[:notice] = "Your account has been created. Check your email for your activation code."
      redirect_to(new_session_path)
    else
      render(:action => 'new')
    end
  end
  
  def update
    if self.current_user.update_attributes(params[:user])
      if params[:commit].include?('Password')
        flash[:notice] = "Your password was successfully updated."
      else
        flash[:notice] = "Your contact info was successfully updated."
      end
      
      redirect_to(edit_account_path)
    else
      render(:action => 'edit')
    end
  end
  
  def reset_activation_code
    if request.post?
      user = User.find_by_username(params[:user][:username])
      
      if user.nil?
        flash[:warning] = "We couldn't find an account with that username."
      else
        user.reset_activation_code
        UserMailer.deliver_reset_activation_code(user)
        
        flash[:notice] = %{
          We just emailed your new activation code to your address, #{user.email}. Check your
          #{@template.link_to('webmail', 'http://www.calvin.edu/go/studentmail/')} to retrieve it.
        }
        redirect_to(new_session_path)
      end
    end
  end
end
