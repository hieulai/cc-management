class Account < ActiveRecord::Base
  belongs_to :builder
  has_many :payments
  has_many :deposits
  
  attr_accessible :name,:balance,:number,:category,:subcategory,:prefix
end
