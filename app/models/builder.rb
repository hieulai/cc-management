class Builder < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :architects
  has_many :suppliers
  has_many :subcontractors
  has_many :clients
  has_many :projects
  has_many :users
  has_many :items
  has_many :categories
  has_many :templates
end
