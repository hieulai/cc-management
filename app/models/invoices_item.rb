class InvoicesItem < ActiveRecord::Base
  belongs_to :invoice
  belongs_to :item
  attr_accessible :amount, :invoice_id, :item_id
end
