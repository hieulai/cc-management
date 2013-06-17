class Project < ActiveRecord::Base
  belongs_to :client
  has_many :estimates
  has_one :tasklist
  
  attr_accessible :name, :project_type, :status, :lead_stage, :progress, :revenue, :start_date, :completion_date,
  :deadline, :schedule_variance, :next_tasks, :check_back, :lead_source, :lead_notes, :project_notes
  
end
