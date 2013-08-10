require 'digest/sha1'
class User < ActiveRecord::Base

  #relations
  belongs_to :builder

  #Variables
  attr_accessible :first_name, :last_name, :email, :primary_phone, :authority, :legacy_salt, :legacy_hashed_password, :password

  #Validations
  #validates :password, length: {in: 1..20}
  validates :email, presence: true, uniqueness: true

  devise :database_authenticatable, :registerable

  #public methods
  def full_name
     "#{first_name} #{last_name}"
  end

  def self.make_salt(email="")
    Digest::SHA1.hexdigest("Use #{email} with #{Time.now} to make salt")
  end

  def self.hash_with_salt(password="", salt="")
    Digest::SHA1.hexdigest("Put #{salt} on the #{password}")
  end

  def valid_password?(password)
    if self.legacy_hashed_password.present?
      if password_match? password
        self.password = password
        self.legacy_hashed_password = nil
        self.save!
        true
      else
        false
      end
    end
    super(password)
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
    legacy_hashed_password == User.hash_with_salt(password,legacy_salt)
  end

  def full_name
     "#{first_name} #{last_name}"
  end

end