# == Schema Information
#
# Table name: people
#
#  id            :integer          not null, primary key
#  first_name    :string(255)
#  last_name     :string(255)
#  email         :string(255)
#  primary_phone :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  deleted_at    :time
#

class Person < ActiveRecord::Base
  acts_as_paranoid
  has_many :profiles, :dependent => :destroy
  attr_accessible :first_name, :last_name, :email, :primary_phone

  validates :email, presence: true, uniqueness: true
end
