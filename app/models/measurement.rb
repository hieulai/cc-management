# == Schema Information
#
# Table name: measurements
#
#  id          :integer          not null, primary key
#  estimate_id :integer
#  name        :string(255)
#  unit        :string(255)
#  amount      :integer
#  stories     :integer
#  CA          :boolean
#  CNC         :boolean
#  CR          :boolean
#  RA          :boolean
#  RNC         :boolean
#  RR          :boolean
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  deleted_at  :time
#

class Measurement < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :estimate

  attr_accessible :name, :unit, :amount, :stories, :CA, :CNC, :CR, :RA, :RNC, :RR, :estimate_id
end
