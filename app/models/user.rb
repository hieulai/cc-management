# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  builder_id             :integer
#  authority              :string(255)
#  first_name             :string(255)
#  last_name              :string(255)
#  email                  :string(255)
#  primary_phone          :string(255)
#  legacy_hashed_password :string(255)
#  legacy_salt            :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  deleted_at             :time
#

require 'digest/sha1'
class User < ActiveRecord::Base
  acts_as_paranoid

  #relations
  belongs_to :builder, :class_name => "Base::Builder"

  #Variables
  attr_accessible :first_name, :last_name, :email, :primary_phone, :authority, :legacy_salt, :legacy_hashed_password, :password

  #Validations
  #validates :password, length: {in: 1..20}
  validates :email, presence: true, uniqueness: true

  devise :database_authenticatable, :registerable, :recoverable

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

  def password_match?(password="")
    legacy_hashed_password == User.hash_with_salt(password,legacy_salt)
  end

  def full_name
     "#{first_name} #{last_name}"
  end

end
