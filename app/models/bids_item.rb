class BidsItem < ActiveRecord::Base
  belongs_to :bid
  belongs_to :item
  attr_accessible :amount, :bid_id, :item_id
end
