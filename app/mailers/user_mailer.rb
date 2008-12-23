class UserMailer < ActionMailer::Base # :nodoc:
  def signup_notification(user)
    setup_email(user)
    @subject += 'Activate Your New Account'
  end
  
  def reset_password(user)
    setup_email(user)
    @subject += 'Your Password Has Been Reset'
  end
  
  protected
    def setup_email(user)
      @recipients  = user.email
      @from        = 'The Book Connection Admin <no-reply@csx.calvin.edu>'
      @subject     = 'The Book Connection - '
      @sent_on     = Time.now
      @body[:user] = user
    end
end
