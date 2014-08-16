# == Schema Information
#
# Table name: prospects
#
#  id                  :integer          not null, primary key
#  builder_id          :integer
#  company             :string(255)
#  first_name          :string(255)
#  last_name           :string(255)
#  email               :string(255)
#  primary_phone       :string(255)
#  primary_phone_tag   :string(255)
#  secondary_phone     :string(255)
#  secondary_phone_tag :string(255)
#  address             :string(255)
#  city                :string(255)
#  state               :string(255)
#  zipcode             :string(255)
#  lead_source         :string(255)
#  last_contacted      :date
#  notes               :text
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  deleted_at          :time
#

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
