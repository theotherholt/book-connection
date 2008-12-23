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
  before_save :encrypt_password
  
  #--
  # Plugins
  #++
  acts_as_state_machine(:initial => :passive)
  
  state :passive
  state :pending,  :enter => :make_activation_code
  state :active,   :enter => :do_activate
  state :suspended
  
  event :register do
    transitions :from  => :passive,
                :to    => :pending,
                :guard => Proc.new { |u| !(u.crypted_password.blank? && u.password.blank?) }
  end
  
  event :activate do
    transitions :from => :pending,
                :to   => :active
  end
  
  event :suspend do
    transitions :from => [ :passive, :pending, :active ],
                :to   => :suspended
  end
  
  event :unsuspend do
    transitions :from  => :suspended,
                :to    => :active,
                :guard => Proc.new { |u| !u.activated_at.blank? }
    
    transitions :from  => :suspended,
                :to    => :pending,
                :guard => Proc.new { |u| !u.activation_code.blank? }
    
    transitions :from => :suspended,
                :to   => :passive
  end
  
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
    #   The user's password.
    #
    # ==== Returns
    # User::
    #   The user object for the given username, given a valid username and password
    #   combination, otherwise nil.
    #
    # ==== Raises
    # AccountNotVerified::
    #   If the user has not yet verified their account (i.e.: user.active? returns false).
    def authenticate(username, password)
      user = self.find_by_username(username)
      unless user.nil?
        if user.active?
          if user.authenticated?(password)
            user.update_attribute(:last_login_at, Time.now)
            return user
          else
            return nil
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
    #   The salt generated by the User model.
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
    #   A random hash of the letters A through F (upper and lower case) and
    #   the numbers 1 through 9.
    def random_hash(size)
      chars = ('a'..'f').to_a + ('A'..'F').to_a + ('1'..'9').to_a
      Array.new(size) { chars[rand(chars.size)] }.join
    end
  end
  
  ##
  # Activates the user if given the correct activation code.
  #
  # ==== Parameters
  # activation<String>::
  #   The user's activation code.
  def activate_with(activation)
    self.activate! if self.pending? && self.activation_code == activation
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
  #   The user's email. If they specify an alternate email, that is returned.
  #   Otherwise, their Calvin email is returned based on their username and
  #   alumni status.
  def email
    if self.alternate_email.blank?
      self.username + ((self.alumni?) ? '@alumni.calvin.edu' : '@students.calvin.edu')
    else
      self.alternate_email
    end
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
  #
  # ==== Notes
  # This method defers to the User model's class encrypt method.
  def encrypt(password)
    self.class.encrypt(password, self.salt)
  end
  
  ##
  # ==== Returns
  # String::
  #   The user's full name.
  #
  # ==== Notes
  # This method is aliased as to_s.
  def name
    "#{self.first_name} #{self.last_name}"
  end
  alias :to_s :name
  
  ##
  # Set's the user's password to a random 8 character string.
  def reset_password
    self.set_password(User.random_hash(8))
  end
  
  ##
  # Set's the user's password and password confirmation at the same time, then
  # saves the model.
  #
  # ==== Parameters
  # password<String>::
  #   The user's plaintext password.
  #
  # ==== Notes
  # This method is really just a convenience method for use on the command line,
  # as well as a few other situations where the program doesn't need password
  # confirmation.
  def set_password(password)
    self.update_attributes(
      :password => password,
      :password_confirmation => password
    )
    self.password = password
  end
  
  ##
  # Updates the user's password if they are able to confirm their old password.
  #
  # ==== Parameters
  # old_password<String>::
  #   The user's current plaintext password.
  # new_password<String>::
  #   The user's desired new password.
  # new_password_confirmation<String>::
  #   The confirmation of the user's desired new password.
  #
  # ==== Returns
  # Boolean::
  #   True if the user gives a correct current password and a matching confirmation
  #   of their new password.
  #
  # ==== Notes
  # This method is a convenience method used in the update password form.
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
    characters = ('A'..'Z').to_a + (2..9).to_a - [ 'I', 'O' ]
    
    begin
      self.activation_code = Array.new(10, '').collect { characters[rand(characters.size)] }.join
    end while self.class.exists?(:activation_code => self.activation_code)
    
    self.deleted_at = nil
  end
  
  ##
  # Sets the user's deleted_at attribute to the current time.
  #
  # ==== Notes
  # I'm not even sure if this works currently. I believe users do really get
  # deleted by Rails still.
  def do_delete
    self.deleted_at = Time.now.utc
  end
  
  ##
  # Sets the user's activated_at attribute and clears their deleted_at and
  # activation_code attributes when the user becomes active.
  def do_activate
    self.activated_at = Time.now.utc
    self.deleted_at = self.activation_code = nil
  end
  
  #--
  # Private Methods
  #++
  private
  
  ##
  # Encrypts the user's plaintext password if it is set. This method generates
  # a password salt if one does not exist, then calls the encrypt method to
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
