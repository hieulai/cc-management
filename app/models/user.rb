class User < ActiveRecord::Base
  attr_accessible :first_name, :last_name, :email, :primary_phone, :password

  belongs_to :builder
end
