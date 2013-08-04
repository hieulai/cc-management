class Payment < ActiveRecord::Base
  belongs_to :account
  
  attr_accessible :amount, :date, :memo
end
