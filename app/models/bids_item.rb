class BidsItem < ActiveRecord::Base
  acts_as_paranoid
  belongs_to :bid
  belongs_to :item
  attr_accessible :amount, :bid_id, :item_id

  scope :chosen, includes(:bid).where("bids.chosen = true")
end
