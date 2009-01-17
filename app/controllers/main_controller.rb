class MainController < ApplicationController # :nodoc:
  skip_before_filter :require_login
  skip_before_filter :verify_authenticity_token
  
  def contact
    if request.post?
      @contact_form = ContactForm.new(params[:contact_form])
      
      if @contact_form.valid?
        ContactFormMailer.deliver_contact(@contact_form)
        
        flash[:notice] = "Thanks for your message. We'll get back to you soon..."
        redirect_to(root_path)
      end
    else
      @contact_form = ContactForm.new
    end
  end
end
