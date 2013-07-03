class Task < ActiveRecord::Base
  
  belongs_to :tasklist
  
  attr_accessible :name, :completed, :time_to_complete, :department
  
end
