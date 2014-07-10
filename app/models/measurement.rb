class Measurement < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :estimate

  attr_accessible :name, :unit, :amount, :stories, :CA, :CNC, :CR, :RA, :RNC, :RR, :estimate_id
end
