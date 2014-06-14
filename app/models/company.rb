class Company < ActiveRecord::Base
  has_one :image, as: :imageable, dependent: :destroy

  attr_accessible :type, :company_name, :year_founded, :office_phone, :website, :address, :city, :state, :zipcode, :tax_id, :logo, :slogan, :image_attributes
  accepts_nested_attributes_for :image
end