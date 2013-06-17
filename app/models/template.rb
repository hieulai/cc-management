class Template < ActiveRecord::Base
  belongs_to :builder
  belongs_to :estimate
  has_many :categories
  
  attr_accessible :name, :cost_total, :margin_total, :price_total, :default
  
end
