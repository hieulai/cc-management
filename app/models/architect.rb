class Architect < ActiveRecord::Base
  belongs_to :builder
  
  attr_accessible :company, :first_name, :last_name, :email, :primary_phone, :secondary_phone, :website, :address, :city, :state, :zipcode, :notes,
  :primary_phone_tag, :secondary_phone_tag
  
  scope :search, lambda{|query| where("company LIKE ? OR first_name LIKE ? OR last_name LIKE ? OR notes LIKE ?",
     "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%")} 
  
  def full_name
     "#{first_name} #{last_name}"
  end
end
