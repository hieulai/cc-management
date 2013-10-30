class Task < ActiveRecord::Base
  include Importable

  belongs_to :tasklist
  default_scope { order("position ASC") }

  attr_accessible :name, :tasklist_id, :completed, :time_to_complete, :department, :position

  HEADERS = ["Name", "Completed", "Time to complete", "Department"]

end
