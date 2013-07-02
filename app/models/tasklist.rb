class Tasklist < ActiveRecord::Base
  
  has_many :tasks
  belongs_to :project
  belongs_to :builder

  attr_accessible :name

end
