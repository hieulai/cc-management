class InvoicesItem < ActiveRecord::Base
  belongs_to :invoice
  belongs_to :item
  attr_accessible :amount, :invoice_id, :item_id

  scope :previous_created_by_item, lambda { |item_id, dt| where("item_id = ? and created_at < ?", item_id, dt) }
end
