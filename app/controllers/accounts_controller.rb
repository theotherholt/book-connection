class AccountsController < ApplicationController # :nodoc:
  skip_before_filter :require_login, :only => [ :new, :create, :activate ]
  
  def activate
    begin
      @user = User.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = "We couldn't find an account with that ID."
      redirect_to(root_path)
    else
      if @user.activate_with(params[:activation])
        flash[:notice] = "Your account is active and ready to go!"
        redirect_to(new_session_path)
      else
        flash[:notice] = "You entered an invalid activation code."
        redirect_to(root_path)
      end
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
    
    if @user.save && @user.register!
      UserMailer.deliver_signup_notification(@user)
      
      flash[:notice] = "Your account has been created. Check your email for your activation code."
      redirect_to(new_session_path)
    else
      render(:action => 'new')
    end
  end
  
  def edit
    @user = self.current_user
  end
  
  def update
    @user = self.current_user
    
    if @user.update_attributes(params[:user])
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
end
