class Tasklist < ActiveRecord::Base
  
  has_many :tasks
  belongs_to :project

  attr_accessible :name

end
