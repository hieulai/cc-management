class Supplier < ActiveRecord::Base
  
  belongs_to :builder, :class_name => "Base::Builder"
  
  attr_accessible :company,:primary_first_name,:primary_last_name,:primary_email,:primary_phone,:secondary_first_name,:secondary_last_name,:secondary_email,
  :secondary_phone,:website,:address,:city,:state,:zipcode,:notes, :primary_phone_tag, :secondary_phone_tag

  scope :search, lambda{|query| where("company ILIKE ? OR primary_first_name ILIKE ? OR primary_last_name ILIKE ? OR secondary_first_name ILIKE ? OR
     secondary_last_name ILIKE ? OR notes ILIKE ?",
     "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%")} 
  
  HEADERS = ["Company", "Primary_First_Name", "Primary_Last_Name", "Primary_Email", "Primary_Phone","Primary_Phone_Tag", 
    "Secondary_First_Name", "Secondary_Last_Name", "Secondary_Email","Secondary_Phone", "Secondary_Phone_Tag", "Website", "Address", "City", "State", "Zipcode", 
              "Notes"]
               
  def full_name
     "#{primary_first_name} #{primary_last_name}"
  end

  def self.to_csv
    CSV.generate do |csv|
      csv << HEADERS
      all.each do |supplier|
        csv << supplier.attributes.values_at(*HEADERS)
      end
    end
  end
  
end
