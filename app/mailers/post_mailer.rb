class PostMailer < ActionMailer::Base # :nodoc:
  def sold_notification(post)
    setup_email(post)
    @recipients = post.user.email
    @subject   += "Your Copy of \"#{post.book.try(:title_with_formatting)}\" Has Sold"
  end
  
  def purchased_notification(post)
    setup_email(post)
    @recipients = post.buyer.email
    @subject   += "You've Purchased \"#{post.book.try(:title_with_formatting)}\""
  end
  
  protected
    def setup_email(post)
      @from          = 'The Book Connection Admin <no-reply@csx.calvin.edu>'
      @subject       = 'The Book Connection - '
      @sent_on       = Time.now
      @body[:seller] = post.user
      @body[:buyer]  = post.buyer
      @body[:post]   = post
      @body[:book]   = post.book
    end
end
