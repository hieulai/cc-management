class Client < ActiveRecord::Base
  
  belongs_to :builder, :class_name => "Base::Builder"
  has_many :projects, dependent: :destroy
  has_many :invoices, :through => :projects
  
  attr_accessible :company, :first_name, :last_name, :email, :primary_phone, :secondary_phone, 
      :address, :city, :state, :zipcode, :notes, :last_contacted, :lead_source, :primary_phone_tag, :secondary_phone_tag
  
  scope :search, lambda{|query| where("company ILIKE ? OR first_name ILIKE ? OR last_name ILIKE ? OR notes ILIKE ? OR lead_source ILIKE ?",
     "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%", "%#{query}%")}

  scope :has_unbilled_invoices, lambda { |builder_id| joins(:invoices).where("clients.builder_id= ? AND (invoices.remaining_amount is NULL OR invoices.remaining_amount > 0)", builder_id).uniq.all }
      
  def full_name
     "#{first_name} #{last_name}"
  end
end
