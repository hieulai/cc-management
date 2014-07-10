class Person < ActiveRecord::Base
  acts_as_paranoid
  has_many :profiles, :dependent => :destroy
  attr_accessible :first_name, :last_name, :email, :primary_phone

  validates :email, presence: true, uniqueness: true
end
