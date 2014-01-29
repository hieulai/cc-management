class ReceiptsItem < ActiveRecord::Base
  belongs_to :receipt
  belongs_to :account
  attr_accessible :name, :description, :amount, :receipt_id, :account_id
end
