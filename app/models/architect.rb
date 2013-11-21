class Architect < ActiveRecord::Base
  belongs_to :builder, :class_name => "Base::Builder"
  
  attr_accessible :company, :first_name, :last_name, :email, :primary_phone, :secondary_phone, :website, :address, :city, :state, :zipcode, :notes,
  :primary_phone_tag, :secondary_phone_tag
  
  scope :search, lambda{|query| where("company ILIKE ? OR first_name ILIKE ? OR last_name ILIKE ? OR notes ILIKE ?",
     "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%")} 
  
  HEADERS = ["Company", "First_Name", "Last_Name", "Email",
           "Primary_Phone","Primary_Phone_Tag", "Secondary_Phone", "Secondary_Phone_Tag", "Website", "Address", "City", "State", "Zipcode", 
           "Notes"]
  
  def full_name
     "#{first_name} #{last_name}"
  end
  
  def self.to_csv
    CSV.generate do |csv|
      csv << HEADERS
      all.each do |architect|
        csv << architect.attributes.values_at(*HEADERS)
      end
    end
  end
  
end
