# == Schema Information
#
# Table name: tasks
#
#  id               :integer          not null, primary key
#  tasklist_id      :integer
#  name             :string(255)
#  completed        :boolean
#  time_to_complete :integer
#  department       :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  position         :integer          default(0)
#  deleted_at       :time
#

class Task < ActiveRecord::Base
  acts_as_paranoid
  include Importable

  belongs_to :tasklist
  default_scope { order("position ASC, id ASC") }

  attr_accessible :name, :tasklist_id, :completed, :time_to_complete, :department, :position

  after_save :convert_project

  validates :name, presence: true

  HEADERS = ["Name", "Completed", "Time to complete", "Department"]

  private
  def convert_project
    if self.tasklist.project && self.tasklist.project.status != Project::PAST && self.tasklist.project.incomplete_tasks.empty?
      self.tasklist.project.update_attributes(:status => Project::PAST)
      self.tasklist.project.committed_estimate.update_attributes(:status => Estimate::PAST)
    end
    true
  end

end
