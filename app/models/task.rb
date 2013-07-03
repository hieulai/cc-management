class Task < ActiveRecord::Base

  belongs_to :tasklist

  attr_accessible :name, :tasklist_id, :completed, :time_to_complete, :department

end
