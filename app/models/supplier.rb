class Supplier < ActiveRecord::Base
  
  belongs_to :builder
  
  attr_accessible :company,:primary_first_name,:primary_last_name,:primary_email,:primary_phone,:secondary_first_name,:secondary_last_name,:secondary_email,
  :secondary_phone,:website,:address,:city,:state,:zipcode,:notes

  def full_name
     "#{first_name} #{last_name}"
  end
end
