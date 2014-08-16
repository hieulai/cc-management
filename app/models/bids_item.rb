# == Schema Information
#
# Table name: bids_items
#
#  id         :integer          not null, primary key
#  bid_id     :integer
#  item_id    :integer
#  amount     :decimal(10, 2)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  deleted_at :time
#

class BidsItem < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :bid
  belongs_to :item
  attr_accessible :amount, :bid_id, :item_id

  scope :chosen, includes(:bid).where("bids.chosen = true")
end
