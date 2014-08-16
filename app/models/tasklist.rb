# == Schema Information
#
# Table name: tasklists
#
#  id         :integer          not null, primary key
#  builder_id :integer
#  project_id :integer
#  name       :string(255)
#  completed  :integer
#  total      :integer
#  default    :boolean
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :time
#

class Tasklist < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :project
  belongs_to :builder, :class_name => "Base::Builder"
  has_many :tasks, dependent: :destroy

  attr_accessible :name, :tasks_attributes, :builder_id
  accepts_nested_attributes_for :tasks, :reject_if => lambda {|x| x[:name].blank?}, :allow_destroy => true


  def to_csv(options = {})
    CSV.generate(options = {}) do |csv|
      csv << Task::HEADERS
      self.tasks.each do |task|
        csv << [task.name, task.completed, task.time_to_complete, task.department]
      end
    end
  end
end
