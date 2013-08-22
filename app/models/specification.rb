class Specification < ActiveRecord::Base
  belongs_to :project
  has_one :category  
  
  attr_accessible :name, :description, :completed
end
