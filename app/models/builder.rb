class Builder < ActiveRecord::Base
  #Relations
  has_many :architects
  has_many :suppliers
  has_many :subcontractors
  has_many :clients
  has_many :projects
  has_many :users
  has_many :items
  has_many :categories
  has_many :templates

  attr_accessible :company_name, :year_founded, :office_phone, :website, :address, :city, :state, :zipcode, :tax_id
end
