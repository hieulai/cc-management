class Estimate < ActiveRecord::Base
  belongs_to :project
  has_many :items
  has_many :measurements , :dependent => :destroy
  
  accepts_nested_attributes_for :measurements
  
  attr_accessible :template, :progress, :status, 
  :deadline, :revenue, :profit, :margin, :notes, :project_id, :measurements_attributes
  
end
