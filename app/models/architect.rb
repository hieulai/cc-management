class Architect < ActiveRecord::Base
  belongs_to :builder
  
  attr_accessible :company, :first_name, :last_name, :email, :primary_phone, :secondary_phone, :website, :address, :city, :state, :zipcode, :notes
  
end
