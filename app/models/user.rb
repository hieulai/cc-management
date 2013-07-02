require 'digest/sha1'
class User < ActiveRecord::Base
 
  #relations
  belongs_to :builder
 
  #Variables
  attr_accessible :first_name, :last_name, :email, :primary_phone, :authority
  attr_protected :hashed_password, :salt
  attr_accessor :password
  
  #Validations
  #validates :password, length: {in: 1..20} 
  validates :email, presence: true, uniqueness: true 
  
  #Callbacks
  before_save :create_hashed_password
  after_save :clear_password
  
  #public methods
  def self.make_salt(email="")
    Digest::SHA1.hexdigest("Use #{email} with #{Time.now} to make salt")
  end
  
  def self.hash_with_salt(password="", salt="")
    Digest::SHA1.hexdigest("Put #{salt} on the #{password}")
  end
  
  def self.authenticate(email="",password="")
    user = User.find_by_email(email)
    if user && user.password_match?(password)
      return user
    else
      return false
    end
  end
  
  def password_match?(password="")
    hashed_password == User.hash_with_salt(password,salt)
  end
  
  def full_name
     "#{first_name} #{last_name}"
  end
  
  private
  
  def create_hashed_password
    unless password.blank?
      self.salt = User.make_salt(email) if salt.blank?
      self.hashed_password = User.hash_with_salt(password, salt)
    end
  end
  
  def clear_password
    self.password = nil
  end
  
end

