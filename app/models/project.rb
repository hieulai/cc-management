class Project < ActiveRecord::Base
  belongs_to :client
  belongs_to :builder
  has_many :estimates
  has_many :bids
  has_many :change_orders
  has_many :specifications
  has_many :purchase_orders
  has_one :tasklist
  

  attr_accessible :name, :project_type, :status, :lead_stage, :progress, :revenue, :start_date, :completion_date,
  :deadline, :schedule_variance, :next_tasks, :check_back, :lead_source, :lead_notes, :project_notes

  def next_tasks n
    incompleted_tasks[0..n]
  end

  def current_progress
    if tasklist.present? && tasklist.tasks.any?
     (1 - incompleted_tasks.count.to_f/tasklist.tasks.count.to_f)*100.00
    else
      0.00
    end
  end

  def incompleted_tasks
    unless tasklist.nil?
      tasklist.tasks.select { |t| !t.completed? }
    else
      Array.new
    end
  end
  
end
