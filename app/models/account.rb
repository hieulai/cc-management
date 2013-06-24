class Account < ActiveRecord::Base
  belongs_to :builder
  
  attr_accessible :name,:balance,:number,:category,:subcategory,:prefix
end
