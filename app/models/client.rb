class Client < ActiveRecord::Base
  
  belongs_to :builder
  has_many :projects, dependent: :destroy
  
  attr_accessible :company, :first_name, :last_name, :email, :primary_phone, :secondary_phone, 
      :address, :city, :state, :zipcode, :notes, :last_contacted, :lead_source
  
  scope :search, lambda{|query| where("company LIKE ? OR first_name LIKE ? OR last_name LIKE ? OR notes LIKE ? OR lead_source LIKE ?",
     "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%")} 
      
  def full_name
     "#{first_name} #{last_name}"
  end
end
