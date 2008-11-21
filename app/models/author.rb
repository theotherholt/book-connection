class Author < ActiveRecord::Base
  #--
  # Validations
  #++
  validates_presence_of :name
  
  #--
  # Relations
  #++
  has_and_belongs_to_many :books
  
  ##
  # ==== Returns
  # String::
  #   The author's name.
  def to_s
    self.name
  end
end
