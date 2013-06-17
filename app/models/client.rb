class Client < ActiveRecord::Base
  
  belongs_to :builder
  has_many :projects
  
  attr_accessible :company, :first_name, :last_name, :email, :primary_phone, :secondary_phone, 
      :address, :city, :state, :zipcode, :notes, :last_contacted, :lead_source
end
