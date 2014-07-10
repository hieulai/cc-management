class Prospect < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :builder, :class_name => "Base::Builder"
  
  attr_accessible :company, :first_name, :last_name, :email, :primary_phone, :secondary_phone, 
      :address, :city, :state, :zipcode, :notes, :last_contacted, :lead_source, :primary_phone_tag, :secondary_phone_tag
  
  scope :search, lambda{|query| where("company ILIKE ? OR first_name ILIKE ? OR last_name ILIKE ? OR notes ILIKE ?",
     "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%")}

  def display_name
    company.presence || main_full_name
  end
      
  def full_name
     "#{first_name} #{last_name}"
  end
  
end
