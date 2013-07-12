class Supplier < ActiveRecord::Base
  
  belongs_to :builder
  
  attr_accessible :company,:primary_first_name,:primary_last_name,:primary_email,:primary_phone,:secondary_first_name,:secondary_last_name,:secondary_email,
  :secondary_phone,:website,:address,:city,:state,:zipcode,:notes, :primary_phone_tag, :secondary_phone_tag

  scope :search, lambda{|query| where("company ILIKE ? OR primary_first_name ILIKE ? OR primary_last_name ILIKE ? OR secondary_first_name ILIKE ? OR
     secondary_last_name ILIKE ? OR notes ILIKE ?",
     "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%")} 
     
  def full_name
     "#{primary_first_name} #{primary_last_name}"
  end
end
