# require 'digest/SHA1'
class User < ActiveRecord::Base
 

  belongs_to :builder
 
  attr_accessible :first_name, :last_name, :email, :primary_phone, :password

  def self.make_salt(email="")
    Digest::SHA1.hexdigest("Use #{email} with #{Time.now} to make salt")
  end
  
  def self.hash_with_salt(password="", salt="")
    Digest::SHA1.hexdigest("Put #{salt} on the #{password}")
  end
end

