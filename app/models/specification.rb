class Specification < ActiveRecord::Base

  belongs_to :builder, :class_name => "Base::Builder"
  belongs_to :project
  belongs_to :estimate
  has_one :category  
  
  attr_accessible :name, :description, :completed, :category, :estimate_id
end
