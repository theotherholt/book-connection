class ContactFormMailer < ActionMailer::Base # :nodoc:
  def contact(contact)
    setup_email(contact)
    @subject    += 'Contact Form Submission'
    @subject    += ' (WITH A POSSIBLE BUG REPORT!)' if contact.bug?
  end
  
  protected
    def setup_email(contact)
      @recipients     = 'Ryan Holt <ryan@theotherholt.com>'
      @from           = 'The Book Connection Admin <no-reply@csx.calvin.edu>'
      @subject        = 'Book Connection - '
      @sent_on        = Time.now
      @body[:contact] = contact
    end
end
