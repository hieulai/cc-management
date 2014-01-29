class UnJobCostedItem < ActiveRecord::Base
  belongs_to :bill
  belongs_to :account
  attr_accessible :account_id, :amount, :bill_id, :description, :name
  default_scope { order(:created_at) }
end
