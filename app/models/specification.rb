# == Schema Information
#
# Table name: specifications
#
#  id          :integer          not null, primary key
#  project_id  :integer
#  name        :string(255)
#  completed   :boolean
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  description :text
#  deleted_at  :time
#  builder_id  :integer
#  estimate_id :integer
#

class Specification < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :builder, :class_name => "Base::Builder"
  belongs_to :project
  belongs_to :estimate
  has_one :category  
  
  attr_accessible :name, :description, :completed, :category, :estimate_id
end
