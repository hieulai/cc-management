class Task < ActiveRecord::Base
  include Importable

  belongs_to :tasklist
  default_scope { order("position ASC, id ASC") }

  attr_accessible :name, :tasklist_id, :completed, :time_to_complete, :department, :position

  after_save :convert_project

  HEADERS = ["Name", "Completed", "Time to complete", "Department"]

  private
  def convert_project
    if self.tasklist.project.status != "Past Project" && self.tasklist.project.incomplete_tasks.empty?
      self.tasklist.project.update_attribute(:status, "Past Project")
      self.tasklist.project.estimates.first.update_attribute(:status, "Past Estimate")
    end
    true
  end

end
