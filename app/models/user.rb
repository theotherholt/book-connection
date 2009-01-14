require 'digest/sha1'

class User < ActiveRecord::Base
  ##
  # Raised when a non-active user attempts to login.
  class AccountNotVerified < StandardError; end
  
  #--
  # Validations
  #++
  validates_presence_of     :first_name, :last_name, :username
  validates_uniqueness_of   :username, :message => 'has been taken'
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_presence_of     :password,                   :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_format_of       :alternate_email, :with => Constants::EMAIL_FORMAT, :allow_blank => true
  
  #--
  # Accessors
  #++
  attr_accessor   :password, :password_confirmation
  attr_accessible :first_name, :last_name, :username, :phone
  attr_accessible :password, :password_confirmation, :alumni, :alternate_email
  
  #--
  # Relations
  #++
  has_many :posts, :dependent => :delete_all
  
  #--
  # Callbacks
  #++
  before_save   :encrypt_password
  before_create :make_activation_code
  
  #--
  # Class Methods
  #++
  class << self
    ##
    # Authenticates a user based on their username and password.
    #
    # ==== Parameters
    # username<String>::
    #   The user's webmail username.
    # password<String>::
    #   The user's plaintext password.
    #
    # ==== Returns
    # User::
    #   The user's record if given a valid username and password, otherwise
    #   nil.
    #
    # ==== Raises
    # AccountNotVerified::
    #   If the user has not yet verified their account.
    def authenticate(username, password)
      user = self.find_by_username(username.split('@').first)
      
      unless user.nil?
        if user.active?
          if user.authenticated?(password)
            user.update_attribute(:last_login_at, Time.now)
            user
          end
        else
          raise AccountNotVerified
        end
      end
    end
    
    ##
    # Encrypts the user's password using SHA1 encryption.
    #
    # ==== Parameters
    # password<String>::
    #   The user's plaintext password.
    # salt<String>::
    #   The password salt.
    #
    # ==== Returns
    # String::
    #   The encrypted password.
    def encrypt(password, salt)
      Digest::SHA1.hexdigest("--#{salt}--NaCl--#{password}--")
    end
    
    ##
    # ==== Parameters
    # size<Integer>::
    #   The desired size of the random hash.
    #
    # ==== Returns
    # String::
    #   A random string of characters.
    def random_hash(size)
      characters = ('A'..'Z').to_a + (2..9).to_a - [ 'I', 'O' ]
      Array.new(size) { characters[ rand(characters.size) ] }.join
    end
  end
  
  ##
  # Sets the user's +activated_at+ field to the current time, activating the
  # user and allowing the user to login.
  def activate!
    self.update_attribute(:activated_at, Time.now)
  end
  
  ##
  # ==== Returns
  # Boolean::
  #   True if the user is active.
  def active?
    !self.activated_at.nil?
  end
  
  ##
  # Checks to see if the plaintext password matches the stored encrypted
  # password.
  #
  # ==== Parameters
  # password<String>
  #   The user's plaintext password.
  #
  # ==== Returns
  # Boolean::
  #   True if the plaintext password matches the stored encrypt password.
  def authenticated?(password)
    self.crypted_password == self.encrypt(password)
  end
  
  ##
  # ==== Returns
  # String::
  #   The user's email. If the user has specified an alternate email, that is
  #   returned. Otherwise, a Calvin webmail address is returned based on the
  #   user's username and alumni status.
  def email
    if self.alternate_email.blank?
      if self.alumni?
        "#{self.username}@alumni.calvin.edu"
      else
        "#{self.username}@students.calvin.edu"
      end
    else
      self.alternate_email
    end
  end
  
  ##
  # ==== Returns
  # String::
  #   The user's name and email address formatted as -- Foo Bar <foo@bar.com>.
  def email_with_name
    "#{self.name} <#{self.email}>"
  end
  
  ##
  # Encrypts the user's password using SHA1 encryption.
  #
  # ==== Parameters
  # password<String>::
  #   The user's plaintext password.
  #
  # ==== Returns
  # String::
  #   The encrypted password.
  def encrypt(password)
    self.class.encrypt(password, self.salt)
  end
  
  ##
  # ==== Returns
  # String::
  #   The user's full name.
  #
  # ==== Notes
  # This method is aliased as +to_s+.
  def name
    "#{self.first_name} #{self.last_name}"
  end
  alias :to_s :name
  
  ##
  # Resets the user's activation code and saves the user.
  #
  # ==== Returns
  # String::
  #   The user's new activation code.
  def reset_activation_code
    self.make_activation_code
    self.save
    self.activation_code
  end
  
  ##
  # Resets the user's password to a random 8 character string and saves the
  # user.
  #
  # ==== Returns
  # String::
  #   The user's new plaintext password.
  def reset_password
    self.password = self.class.random_hash(8)
    self.save_with_validation(false)
    self.password
  end
  
  ##
  # Sets the user's +activated_at+ field to nil, effectively suspending that
  # user.
  def suspend!
    self.update_attribute(:activated_at, nil)
  end
  
  ##
  # Updates the user's password if they are able to confirm their old password.
  #
  # ==== Parameters
  # old_password<String>::
  #   The user's current plaintext password.
  # new_password<String>::
  #   The user's new password.
  # new_password_confirmation<String>::
  #   Confirmation of the user's new password.
  #
  # ==== Returns
  # Boolean::
  #   True if the password update succeeds.
  def update_password(old_password, new_password, new_password_confirmation)
    if self.authenticated?(old_password)
      if new_password.blank?
        false
      elsif new_password == new_password_confirmation
        self.password = new_password
        self.password_confirmation = new_password_confirmation
        self.save
      else
        false
      end
    else
      false
    end
  end
  
  #--
  # Protected Methods
  #++
  protected
  
  ##
  # Generates a random activation code to be emailed to the user during
  # registration.
  def make_activation_code
    begin
      self.activation_code = self.class.random_hash(10)
    end while self.class.exists?(:activation_code => self.activation_code)
  end
  
  #--
  # Private Methods
  #++
  private
  
  ##
  # Encrypts the user's plaintext password if it is set. This method generates
  # a password salt if one does not exist, then calls the +encrypt+ method to
  # do the actual encryption.
  def encrypt_password
    return if self.password.blank?
    
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{self.username}--") if self.new_record?
    self.crypted_password = self.encrypt(self.password)
  end
  
  ##
  # ==== Returns
  # Boolean::
  #   True if the user doesn't yet have an encrypted password, or if the user
  #   has set a new plaintext password.
  def password_required?
    self.crypted_password.blank? || !self.password.blank?
  end
end
