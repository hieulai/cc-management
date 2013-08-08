class Bid < ActiveRecord::Base
  belongs_to :project
  has_one :vendor
  has_one :category
  
  attr_accessible :amount, :notes, :chosen
end
