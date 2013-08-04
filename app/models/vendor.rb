class Vendor < ActiveRecord::Base
  belongs_to :builder
  
  attr_accessible :company,:vendor_type,:trade,:primary_first_name,:primary_last_name,:primary_email,:primary_phone1,:primary_phone2,:secondary_first_name,:secondary_last_name,:secondary_email,
  :secondary_phone1,:secondary_phone2,:website,:address,:city,:state,:zipcode,:notes, :primary_phone1_tag,:primary_phone2_tag, :secondary_phone1_tag, :secondary_phone2_tag

  scope :search, lambda{|query| where("company ILIKE ? OR vendor_type ILIKE ? OR trade ILIKE ? OR primary_first_name ILIKE ? OR primary_last_name ILIKE ? OR secondary_first_name ILIKE ? OR
     secondary_last_name ILIKE ? OR notes ILIKE ?",
     "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%")} 
     
  def full_name
     "#{primary_first_name} #{primary_last_name}"
  end
  
end
