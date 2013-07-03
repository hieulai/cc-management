class Tasklist < ActiveRecord::Base
  
  belongs_to :project
  belongs_to :builder
  has_many :tasks, :dependent => :destroy

  attr_accessible :name, :tasks_attributes
  accepts_nested_attributes_for :tasks, :reject_if => lambda {|x| x[:name].blank?}, :allow_destroy => true

end
