class ContactForm < ActiveForm
  #--
  # Validations
  #++
  validates_presence_of :message
  validates_format_of   :email, :with => Constants::EMAIL_FORMAT, :allow_blank => true
  
  #--
  # Accessors
  #++
  attr_accessor :name, :email, :subject, :bug, :message
  
  ##
  # ==== Returns
  # Boolean::
  #   True if the user checked off that this message is a bug report.
  def bug?
    !self.bug.to_i.zero?
  end
  
  ##
  # ==== Returns
  # String::
  #   The user's name if they set one, otherwise N/A.
  def name_with_formatting
    (self.name.blank?) ? 'N/A' : self.name
  end
  
  ##
  # ==== Returns
  # String::
  #   The user's email if they set one, otherwise N/A.
  def email_with_formatting
    (self.email.blank?) ? 'N/A' : self.email
  end
  
  ##
  # ==== Returns
  # String::
  #   The subject of the user's message if they set one, otherwise N/A.
  def subject_with_formatting
    (self.subject.blank?) ? 'N/A' : self.subject
  end
end